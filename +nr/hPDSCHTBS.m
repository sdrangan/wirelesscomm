%hPDSCHTBS 5G PDSCH transport block size determination
%   TBS = hPDSCHTBS(CHS,NDRE,SCALING) returns the transport block sizes
%   associated with a PDSCH transmission, as defined in TS 38.214 5.1.3.2. 
%
%   The PDSCH specific configuration input, CHS, must be a structure
%   including the fields:
%   TargetCodeRate      - Code rate used to calculate transport block sizes
%   PRBSet              - PRBs allocated to the PDSCH (0-based indices)
%   NLayers             - Total number of layers
%   Modulation          - Modulation scheme(s) ('QPSK','16QAM','64QAM','256QAM')
%
%   The second input, NDRE, is the number of RE allocated per PRB to
%   the PDSCH (N'RE) in the slot, accounting for DM-RS, CDM groups and any
%   additional overhead (Xoh-PDSCH). The optional input, SCALING, defines
%   an optional scaling factor which can be applied to the intermediate
%   number of information bits, NInfo, that is calculated in step 2 of the
%   TBS determination calculations. By default, the scaling equals 1.
% 
%   Examples:
%    
%   pdsch = struct();
%   pdsch.TargetCodeRate = 0.5;
%   pdsch.PRBSet = [0:99];
%   pdsch.NLayers = 2;  
%   pdsch.Modulation = '16QAM';  
%   nred = 12*14;
% 
%   tbs = hPDSCHTBS(pdsch,nred)
%
%   pdsch = struct();
%   pdsch.TargetCodeRate = 0.5;
%   pdsch.PRBSet = [0:99];
%   pdsch.NLayers = 5;
%   pdsch.Modulation = ["16QAM","256QAM"];
%   nred = 12*14;
% 
%   tbs = hPDSCHTBS(pdsch,nred)
% 
%   See also nrDLSCH, nrDLSCHDecoder, hPDSCHResources.

%   Copyright 2018-2019 The MathWorks, Inc.

function tbs = hPDSCHTBS(pdsch,nred,scaling)
    
    % Set up the relevant input parameter values
    if nargin < 3
        scaling = 1;
    end
    
    % Establish the number of codewords in play from the total number of layers
    % then the number of layers per codeword
    nl = pdsch.NLayers;
    ncw = 1 + (nl > 4);                         % Number of codewords, deduced from total layers 
    nlayers = fix((nl + (0:ncw-1))/ncw);        % Number of layers per codeword
    
    % Establish rate per codeword
    rate = pdsch.TargetCodeRate;
    rate = repmat(rate,1,ceil(ncw/length(rate)));   % Scalar expand
    rate = rate(1:ncw);                             % Then limit, if required
    
    % Validate modulation type and translate into bits per symbol
    fullmodlist = ["pi/2-BPSK","BPSK","QPSK","16QAM","64QAM","256QAM"]'; % All NR mod schemes
    modulation = reshape(string(pdsch.Modulation),1,[]);             % Turn into a string row
    qm = [1 1 2 4 6 8]*(lower(modulation) == lower(fullmodlist));     % Test each element against all mods then multiply against bps
    if ~all(qm)
        error("The modulation (%s) must be one of the set (%s).",join(modulation(logical(qm == 0))), join(fullmodlist',','));
    end
    
    % Number of PRB in the allocation
    nprb = length(pdsch.PRBSet);
    
    % Get total number of REs allocated for PDSCH
    nre = min(156,nred)*nprb;
    
    % Obtain intermediate number of information bits (step 2, Ninfo)
    ninfo = scaling*nre*rate.*qm.*nlayers;
    
    % Calculate the TBS for the codewords (steps 3 and 4)
    tbs = arrayfun(@(n,r)determineTBS(n,r),ninfo(1:ncw),rate);
   
end

% Perform TBS calculation
function tbs = determineTBS(ninfo,rate)

    % TBS determination
    if ninfo <= 3824  % (step 3)
        % Get quantized intermediate number of information bits
        n = max(3,floor(log2(ninfo))-6);
        ninfod = max(24,2^n*floor(ninfo/2^n));
        % Search the TBS table
        tbsTab = tbstable();
        for t = 1:length(tbsTab)
            tbs = tbsTab(t);
            if tbs >= ninfod
                return;
            end
        end
    else % ninfo > 3824 (step 4)
        
        % Get quantized intermediate number of information bits
        n = floor(log2(ninfo-24))-5;
        ninfod = max(3840,2^n*round((ninfo-24)/2^n));
        if rate <= 0.25
            C = ceil((ninfod+24)/3816); 
            tbs = 8*C*ceil((ninfod+24)/(8*C))-24;
        else
            if ninfod > 8424
                C = ceil((ninfod+24)/8424); 
                tbs = 8*C*ceil((ninfod+24)/(8*C))-24;
            else
                tbs = 8*ceil((ninfod+24)/8)-24;
            end
        end
    end

end

% TS 38.214 table 5.1.3.2-2
function tbs = tbstable()
    % Construct the static table 
    persistent tbstable;
    if isempty(tbstable)
        tbs = [24		336		1288	
              32		352		1320	
              40		368		1352	
              48		384		1416		
              56		408		1480		
              64		432		1544		
              72		456		1608		
              80		480		1672		
              88		504		1736		
              96		528		1800		
             104		552		1864		
             112		576		1928		
             120		608		2024		
             128		640		2088		
             136		672		2152		
             144		704		2216		
             152		736		2280		
             160		768		2408		
             168		808		2472		
             176		848		2536		
             184		888		2600		
             192		928		2664		
             208		984		2728		
             224		1032 	2792		
             240		1064	2856		
             256		1128	2976		
             272		1160	3104		
             288		1192	3240		
             304		1224	3368		
             320		1256	3496];		
        tbstable = tbs(:);
        tbstable = [tbstable; 3624; 3752; 3824];
    end
    tbs = tbstable;
end

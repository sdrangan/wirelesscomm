%hPDSCHResources 5G NR PDSCH, DM-RS, and PT-RS resource element indices, DM-RS and PT-RS values
%   [IND,DMRSIND,DMRS,PTRSIND,PTRS,INFO] = hPDSCHResources(GNB,CHS) returns
%   the resource element (RE) indices for a 5G NR PDSCH transmission, along
%   with the associated PDSCH DM-RS and PT-RS, for a given time (symbols)
%   and frequency (PRBs) allocation of the PDSCH, the DM-RS and PT-RS
%   configuration. The 1-based linear PDSCH indices are returned in matrix,
%   IND. They are defined relative to a three-dimensional RE grid
%   representing a 14/12-symbol slot for the full carrier (in the PDSCH
%   numerology) across the layers/DM-RS ports of the PDSCH. Each column of
%   IND represents the grid locations for a separate layer/port (the third
%   dimension of the grid). The DM-RS and PT-RS RE indices have the same
%   format and are returned in matrices DMRSIND and PTRSIND respectively.
%   The complex values of DM-RS and PT-RS sequences are also returned in
%   matrices, DMRS and PTRS respectively. Additional information about the
%   DM-RS, PT-RS, and resourcing is returned in the structure INFO.
%
%   [IND,DMRSIND,DMRS,INFO] = hPDSCHResources(GNB,CHS) returns the resource
%   element (RE) indices for a 5G PDSCH transmission, along with the
%   associated PDSCH DM-RS symbols and indices.
%
%   The cell-wide settings input, GNB, must be a structure including
%   the fields:
%   NRB               - Number of downlink resource blocks for the carrier
%                       or bandwidth part (in the PDSCH numerology)
%   CyclicPrefix      - Optional. Cyclic prefix length 
%                       ('Normal'(default),'Extended')
%   SubcarrierSpacing - Optional. Subcarrier Spacing (kHz)
%                       (15(default),30,60,120,240)
%   RBOffset          - Optional. Position of BWP in the SCS carrier.
%                       (default 0)
%                       Only applies if pdsch.VRBToPRBInterleaving is set
%                       to true.
%
%   The PDSCH specific input, CHS, must be a structure including the
%   fields:
%   NSlot                   - Optional. Slot number of PDSCH transmission
%                             (default 0)
%   PRBSet                  - PRBs allocated to the PDSCH (0-based indices)
%   PRBRefPoint             - Optional. PRB index that PRBSet is relative to
%                             (0-based) (default 0)
%   SymbolSet               - OFDM symbols allocated to the PDSCH within the slot
%                             (including DM-RS symbols, 0-based indices, max range 0...13)
%   PortSet                 - DM-RS ports used by PDSCH
%                             (0-based indices, max range 0...11,
%                             mapping to ports p=1000...1011 respectively)
%   NLayers                 - Number of layers
%   Modulation              - Modulation type(s) of codeword(s)
%                             ('QPSK','16QAM','64QAM','256QAM')
%   Reserved                - Optional. Reserved PRB patterns 
%                             (structure array, see below)
%   ReservedREs             - Optional. Reserved REs (0-based indices)
%                             which are not available for PDSCH due to the
%                             presence of channel state information
%                             reference signal (CSI-RS) and LTE cell
%                             specific reference signal in a particular
%                             slot
%   RNTI                    - Optional. Radio network temporary identifier
%                             (0...65535) (default 1)
%   DMRSConfigurationType   - DM-RS configuration type (1,2)
%   NumCDMGroupsWithoutData - Optional. Number of CDM groups without data
%                             (1(default),2,3)
%   NIDNSCID                - DM-RS scrambling identity (0...65535)
%   NSCID                   - DM-RS scrambling initialization (0,1)
%   VRBToPRBInterleaving    - Optional. Enable or disable interleaved
%                             resource mapping (false(default),true)
%   VRBBundleSize           - Optional. vrb-ToPRB-Interleaver parameter
%                             (2(default),4)
%                             Only applies if CHS.VRBToPRBInterleaving is
%                             set to true
%   EnablePTRS              - Optional. Enable PT-RS (0(default),1)
%   PTRSTimeDensity         - Optional. Time density of PT-RS (L_PT-RS)
%                             (1(default),2,4)
%   PTRSFrequencyDensity    - Optional. Frequency density of PT-RS (K_PT-RS)
%                             (2(default),4)
%   PTRSREOffset            - Optional. Resource element offset
%                             ('00'(default),'01','10','11')
%   PTRSPortSet             - Optional. PT-RS antenna port set. It must be
%                             scalar and a subset of DM-RS antenna ports.
%                             (default is lowest DM-RS port number)
%
%   The DM-RS OFDM symbol locations can either be defined explicitly 
%   using the single parameter:
%   DMRSSymbolSet           - OFDM symbols containing the DM-RS within the 
%                             PDSCH allocation in slot 
%                             (0-based indices, max range 0...13)
%   or, defined implicitly via the following group of DM-RS parameters:
%   PDSCHMappingType        - PDSCH mapping type 
%                             ('A'(slot-wise),'B'(non slot-wise))
%   DMRSTypeAPosition       - Mapping type A only. First DM-RS symbol position
%                             (2,3)
%   DMRSLength              - Number of consecutive front-loaded DM-RS OFDM
%                             symbols (1(single symbol),2(double symbol))
%   DMRSAdditionalPosition  - Additional DM-RS symbol positions
%                             (max range 0...3)
% 
%   Periodically recurring patterns of reserved PRB can be defined using
%   the 'Reserved' parameter. These PRBs will be excluded from the
%   generated indices and the DL-SCH/PDSCH processing should rate-match
%   around them. It can be used to exclude SS/PBCH, CORESETs/PDCCH and
%   other resources, as defined in TS 38.214 section 5.1.4. This parameter
%   takes the format of a structure array, where each element defines a
%   separate pattern. Each element, i, of the array must contain these
%   fields:
%   Reserved(i).PRB     - Reserved PRB (0-based indices, defined as a
%                         vector or cell array)
%   Reserved(i).Symbols - OFDM symbols associated with reserved PRB 
%                         (0-based indices, spanning one or more slots)
%   Reserved(i).Period  - Total number of slots in the pattern period
% 
%   The reserved PRB indices can be specified as a vector or a cell array.
%   If the PRB indices are defined as a vector, then the same PRBs are
%   excluded in each OFDM symbol in the pattern. If the PRB indices are
%   defined as a cell array, then each cell specifies the excluded PRBs for
%   the associated OFDM symbol in the pattern. In the latter case, the
%   length of the PRB cell array should match the length of the 'Symbols'
%   field, i.e. an individual set of PRBs is defined for each reserved
%   symbol. The symbols that form the time-domain locations of the reserved
%   pattern can be greater than 13 and therefore cover multiple slots. The
%   overall pattern will repeat itself every 'Period' slots. If this field
%   is empty then the pattern will not cyclically repeat itself.
%
%   In terms of frequency domain DM-RS density, there are two different RRC
%   signaled configuration types ('dmrs-Type'). Configuration type 1
%   defines 6 subcarriers per PRB per antenna port, comprising alternate
%   subcarriers. Configuration type 2 defines 4 subcarriers per PRB per
%   antenna ports, consisting of 2 groups of 2 neighboring subcarriers.
%   Different shifts are applied to the sets of subcarriers used,
%   depending on the associated antenna port or CDM group. For type 1,
%   there are 2 possible CDM groups/shifts across up to 8 possible antenna
%   ports (p=1000...1007), and, for type 2, there are 3 possible CDM
%   groups/shifts across 12 ports (p=1000...1011). See TS 38.211 section
%   7.4.1.1 for the full configuration details.
%
%   In terms of the time-domain DM-RS symbol positions, the PDSCH mapping
%   type ('PDSCHMappingType') can be either slot-wise (type A) or non
%   slot-wise (type B). When a UE is scheduled to receive PDSCH by a DCI,
%   this mapping type is signaled by the time-domain resource field in the
%   grant. The field acts as an index into an RRC configured table where
%   each row in the table specifies a combination of mapping type, slot
%   offset, K0, the symbol start and length indicator, SLIV. The mapping
%   type specifies the relative locations of the associated DM-RS. For
%   slot-wise mapping type A, the first DM-RS symbol is signaled by a field
%   in the MIB to be either 2 or 3 ('dmrs-TypeA-Position'). For the non
%   slot-wise mapping type B, the first DM-RS symbol is always the first
%   symbol of the PDSCH time allocation.
% 
%   The maximum number of DM-RS OFDM symbols used by a UE is configured by
%   RRC signaling ('dmrs-AdditionalPosition' and 'maxLength'). The DM-RS
%   can be a set of single symbols, distributed roughly uniformly across
%   the allocated PDSCH symbols, or 1 or 2 pairs of neighboring or 'double
%   symbol' DM-RS. The 'maxLength' RRC parameter (1 or 2 respectively)
%   configures whether only single symbol DM-RS or either single or double
%   symbol DM-RS are used. In the latter case, the actual selection is
%   signaled in the DCI format 1_1 message. The 'dmrs-AdditionalPosition'
%   higher-layer parameter defines the number of single or double symbol
%   DM-RS that are transmitted. The valid combinations of these two
%   parameters is given by TS 38.211 tables 7.4.1.1.2-3 and 7.4.1.1.2-4. In
%   this function, the value of the 'DMRSLength' input parameter directly
%   controls whether either single or double symbols are used.
%
%   INFO is the output structure containing the fields:
%   G             - Bit capacity of the PDSCH. This is should be the
%                   length of codeword to be output from the DL-SCH 
%                   transport channel
%   Gd            - Number of resource elements per layer/port, equal to 
%                   the number of rows in the PDSCH indices
%   NREPerPRB     - Number of RE per PRB allocated to PDSCH (not accounting
%                   for any reserved resources)
%   DMRSSymbolSet - The symbol numbers in a slot containing DM-RS (0-based)
%   CDMGroups     - CDM groups associated with the DM-RS antenna ports
%   CDMLengths    - A 2-element row vector [FD TD] specifying the length of
%                   FD-CDM and TD-CDM despreading required during channel
%                   estimation. The values depend on the frequency and
%                   time masks applied to groups of antenna ports
%   PTRSSymbolSet - The symbol numbers in a slot containing PT-RS (0-based)
%
%   Example:
%   % Display the locations of the PDSCH and PDSCH DM-RS resource elements 
%   % in a slot. 
%   
%   % Set the number of downlink carrier or BWP resource blocks and the 
%   % numerology (subcarrier spacing and cyclic prefix)
%   gnb = struct('NRB',50);
%   gnb.SubcarrierSpacing = 15;
%   gnb.CyclicPrefix = 'Normal';
%   gnb.RBOffset = 0;
%   
%   % Get the number of OFDM symbols in a slot
%   symbperslot = sum(strcmpi(gnb.CyclicPrefix,["Normal","Extended"]) .* [14 12]);
% 
%   % Specify the basic PDSCH allocation properties to be full band, full
%   % slot using 2 layers/ports
%   pdsch = struct();
%   pdsch.NSlot = 0;                   % Slot number
%   pdsch.PRBSet = 0:gnb.NRB-1;        % Full band PRBs allocated to the PDSCH
%   pdsch.SymbolSet = 0:symbperslot-1; % Full slot allocation to the PDSCH
%   pdsch.PortSet = [0,2];             % Use DM-RS ports p=1000 and p=1002
%   pdsch.Modulation = 'QPSK';         % Modulation type
%
%   % Exclude some PRBs (e.g. for a CORESET) in the middle of the carrier 
%   % or BWP in the first two symbols in the slot
%   pdsch.Reserved.PRB = fix(gnb.NRB/2) + (-4:5);
%   pdsch.Reserved.Symbols = [0,1];
%   pdsch.Reserved.Period = 1;
% 
%   % Configure the PDSCH DM-RS for config type 1 and slot-wise, type A
%   % mapping. Use double symbols for front-loaded DM-RS and configure an
%   % additional symbol pair towards the end of the slot
%   pdsch.DMRSConfigurationType = 1;  % DM-RS configuration type (1,2)
%   pdsch.NIDNSCID = 1;               % DM-RS scrambling identity (0...65535)
%   pdsch.NSCID = 0;                  % DM-RS scrambling initialization (0,1)
%   pdsch.PDSCHMappingType = 'A';     % Slot-wise PDSCH mapping type
%   pdsch.DMRSTypeAPosition = 2;      % First DM-RS symbol position for type A
%   pdsch.DMRSLength = 2;             % Specify double front-loaded DM-RS
%   pdsch.DMRSAdditionalPosition = 1; % Specify an additional DM-RS pair
%   pdsch.NumCDMGroupsWithoutData = 3;% CDM groups without data
% 
%   % Configure the PT-RS with frequency density set to 2, time density set
%   % to 1, resource element offset set to '00'
%   pdsch.EnablePTRS = 1;             % Enable or disable PT-RS (1 or 0)
%   pdsch.PTRSFrequencyDensity = 2;   % Frequency density (2,4)
%   pdsch.PTRSTimeDensity = 1;        % Time density (1,2,4)
%   pdsch.PTRSREOffset = '00';        % Resource element offset ('00','01','10','11')
%
%   % Configure the parameters of carrier and CSI-RS
%   carrier = nrCarrierConfig;
%   carrier.NSlot = pdsch.NSlot;       % Slot number
%   csirs = nrCSIRSConfig;
%   csirs.SymbolLocations = 5;
%   csirs.NumRB = 50;        % Number of RBs allocated for CSI-RS
%
%   % Initialize the slot grid
%   slotgrid = zeros(12*gnb.NRB,symbperslot,max([length(pdsch.PortSet) csirs.NumCSIRSPorts]));
%
%   % Generate 1-based carrier oriented CSI-RS indices in subscript form
%   [csirsInd,~] = nrCSIRSIndices(carrier,csirs,'IndexStyle','subscript');
%
%   % Change the orientation of CSI-RS indices to BWP
%   bwpCSIRSInd = [csirsInd(:,1)-gnb.RBOffset*12 csirsInd(:,2) csirsInd(:,3)];
%
%   % Linearize BWP oriented CSI-RS indices
%   csirsLinInd = sub2ind(size(slotgrid),bwpCSIRSInd(:,1),...
%                         bwpCSIRSInd(:,2),bwpCSIRSInd(:,3));
%
%   % Add 0-based CSI-RS indices to ReservedREs field of pdsch
%   pdsch.ReservedREs = csirsLinInd - 1;
%
%   % Display PDSCH and DM-RS RE locations of the first port of the grid
%   [ind,dmrsind,dmrs,ptrsind,ptrs,info] = hPDSCHResources(gnb,pdsch);
%   slotgrid(ind) = 20;                 % Use light blue for PDSCH RE 
%   slotgrid(dmrsind) = 40*abs(dmrs);   % Use green for DM-RS RE
%   slotgrid(ptrsind) = 70*abs(ptrs);   % Use yellow for PT-RS RE
%   figure;
%   imagesc(slotgrid(:,:,1));
%   title('PDSCH, DM-RS and PT-RS resource elements');
%   axis('xy'), xlabel('Symbols'), ylabel('Subcarriers');
%  
%   See also hPUSCHResources.

%   Copyright 2018-2020 The MathWorks, Inc.

function [pdschIndices,dmrsIndices,dmrsSymbols,varargout] = hPDSCHResources(gnb,pdsch)

    % Argument check 
    narginchk(2,2);

    % Continue to support the older v15.2.0 RRC derived parameter names in this function
    pmap = [
        % v15.2.0           ->       v15.3.0  
        "DL_DMRS_add_pos"       "DMRSAdditionalPosition";    % dmrs-AdditionalPosition
        "DL_DMRS_max_len"       "DMRSLength";                % maxLength - DMRS-DownlinkConfig RRC
        "DL_DMRS_typeA_pos"     "DMRSTypeAPosition";         % dmrs-TypeA-Position (2,3)
        "DL_DMRS_config_type"   "DMRSConfigurationType"   ]; % dmrs-Type (1,2)

    % Map across older parameter names, if present at the input
    pwarningstr = 'The %s parameter name is based on a pre-v15.3.0 version of the 3GPP NR standard. Use %s instead.';   
    for i=1:size(pmap,1)
        if isfield(pdsch,pmap(i,1))
            pdsch.(pmap(i,2)) = pdsch.(pmap(i,1));
            warning('nr5g:DMRSParametersRelease15',pwarningstr,pmap(i,1), pmap(i,2));
            pdsch = rmfield(pdsch,pmap(i,1));
        end
    end

    % Map across 'NDLRB' to 'NRB' parameter name, if present at the input
    if isfield(gnb,'NDLRB')
        gnb.NRB = gnb.NDLRB;
        warning('nr5g:DMRSParametersRelease15',pwarningstr,'NDLRB','NRB');
        gnb = rmfield(gnb,'NDLRB');
    end

    % Get the carrier and pdsch objects from the input structures
    [carrier,pdschObj,indNonContig] = convertStructToObjects(gnb,pdsch);
    numSymNonContig = numel(indNonContig); % Number of OFDM symbols that are not part of the contiguous symbol allocation

    % Get the number of layers
    nLayers = pdschObj.NumLayers;

    % Get the PDSCH resource element indices and structural information
    [pdschIndicesAll,gInfo] = nrPDSCHIndices(carrier,pdschObj);
    pdschIndices = reshape(double(pdschIndicesAll),[],nLayers);

    % Get the PDSCH DM-RS and PT-RS OFDM symbol locations within the
    % allocated OFDM symbols
    nDMRSSym = numel(gInfo.DMRSSymbolSet);
    nPTRSSym = numel(gInfo.PTRSSymbolSet);
    if numSymNonContig
        % Remove the DM-RS and PT-RS OFDM symbol locations, which are not
        % part of allocated OFDM symbols
        dmrsLogicalMatrix = repmat(gInfo.DMRSSymbolSet,numSymNonContig,1) == repmat(indNonContig,1,nDMRSSym);
        dmrsLogicalIndex = ~sum(dmrsLogicalMatrix,1);
        ptrsLogicalMatrix = repmat(gInfo.PTRSSymbolSet,numSymNonContig,1) == repmat(indNonContig,1,nPTRSSym);
        ptrsLogicalIndex = ~sum(ptrsLogicalMatrix,1);
    else
        dmrsLogicalIndex = true(nDMRSSym,1);
        ptrsLogicalIndex = true(nPTRSSym,1);
    end
    dmrsSymbolSet = gInfo.DMRSSymbolSet(dmrsLogicalIndex);
    ptrsSymbolSet = gInfo.PTRSSymbolSet(ptrsLogicalIndex);

    % Get the PDSCH DM-RS symbols and indices
    if ~isempty(dmrsSymbolSet)
        dmrsIndices = reshape(double(nrPDSCHDMRSIndices(carrier,pdschObj)),[],nLayers);
        dmrsSymbols = reshape(nrPDSCHDMRS(carrier,pdschObj),[],nLayers);
    else
        dmrsIndices = zeros(0,nLayers);
        dmrsSymbols = zeros(0,nLayers);
    end

    % Get the PDSCH PT-RS symbols and indices
    if ~isempty(gInfo.PTRSSymbolSet) && ~isempty(dmrsSymbolSet)
        % Assign the PDSCH DM-RS OFDM symbol locations, which are within
        % the allocated OFDM symbols to CustomSymbolSet
        pdschObj.DMRS.CustomSymbolSet = dmrsSymbolSet;
        ptrsIndices = double(nrPDSCHPTRSIndices(carrier,pdschObj));
        ptrsSymbols = nrPDSCHPTRS(carrier,pdschObj);
    else
        ptrsIndices = zeros(0,1);
        ptrsSymbols = zeros(0,1);
    end

    % Get the number of resource elements (RE) in a resource block (RB)
    % allocated for PDSCH
    if numSymNonContig
        % When DM-RS OFDM symbol indices are not within the OFDM symbols
        % allocated for PDSCH, get the number of REs in an RB used for data

        % DM-RS subcarrier (SC) locations in an RB
        if pdschObj.DMRS.DMRSConfigurationType==1
            % Type 1: 6 DM-RS SC per PRB per CDM (every other SC)
            dmrssc = [0 2 4 6 8 10]';                   % RE indices in an RB
            dshiftsnodata = 0:min(pdschObj.DMRS.NumCDMGroupsWithoutData,2)-1; % Delta shifts for CDM groups without data
        else
            % Type 2: 4 DM-RS SC per PRB per CDM (2 groups of 2 SC)
            dmrssc = [0 1 6 7]';                        % RE indices in an RB
            dshiftsnodata = 2*(0:min(pdschObj.DMRS.NumCDMGroupsWithoutData,3)-1); % Delta shifts for CDM groups without data
        end
        dshifts = pdschObj.DMRS.DeltaShifts;

        % Non DM-RS resource elements in a DM-RS containing symbol
        fullprb = ones(12,1);        % Binary map of all the subcarriers in an RB
        dshiftsComp = [dshifts dshiftsnodata];
        dmrsre = repmat(dmrssc,1,numel(dshiftsComp)) + repmat(dshiftsComp, numel(dmrssc),1);
        fullprb(dmrsre+1) = 0;       % Clear all RE which will carry DM-RS in at least one port
        pdschre = find(fullprb)-1;   % Find PDSCH (non DM-RS) RE in a DM-RS containing symbol
        
        nDMRSSym = length(dmrsSymbolSet);
        nREPerPRB = 12*(length(unique(pdsch.SymbolSet(:)))-nDMRSSym)+numel(pdschre)*nDMRSSym;
    else
        nREPerPRB = gInfo.NREPerPRB;
    end

    % Combine information into output structure
    pdschInfo.G = gInfo.G;
    pdschInfo.Gd = gInfo.Gd;
    pdschInfo.NREPerPRB = nREPerPRB;
    pdschInfo.DMRSSymbolSet = dmrsSymbolSet;
    pdschInfo.CDMGroups = pdschObj.DMRS.CDMGroups;
    pdschInfo.CDMLengths = pdschObj.DMRS.CDMLengths;
    pdschInfo.PTRSSymbolSet = ptrsSymbolSet;

    % Assign the outputs based on number of output arguments
    if nargout <= 4
        % [pdschIndices,dmrsIndices,dmrsSymbols,pdschInfo]
        varargout{1} = pdschInfo;
    else
        % [pdschIndices,dmrsIndices,dmrsSymbols,ptrsIndices,ptrsSymbols,pdschInfo]
        varargout{1} = ptrsIndices;
        varargout{2} = ptrsSymbols;
        varargout{3} = pdschInfo;
    end

end

function [carrier,pdsch,ind] = convertStructToObjects(gnb,chs)
%convertStructToObjects Provides the configuration objects given structures
%
%   [CARRIER,PDSCH,IND] = convertStructToObjects(GNB,CHS) provides the
%   carrier configuration object CARRIER and physical downlink shared
%   channel object PDSCH, given the input structures GNB-wide settings GNB
%   and channel specific transmission configuration CHS. This function also
%   provides the OFDM symbol indices IND that are not part of the
%   contiguous symbol allocation.

    % Get the carrier configuration with the inputs gnb and chs
    carrier = nrCarrierConfig;
    carrier.NSizeGrid = gnb.NRB;
    carrier = passign(gnb,carrier,'NCellID');
    carrier = passign(gnb,carrier,'SubcarrierSpacing');
    carrier = passign(gnb,carrier,'CyclicPrefix');
    carrier = passign(gnb,carrier,'RBOffset','NStartGrid');
    carrier = passign(chs,carrier,'NSlot');

    % Get the pdsch configuration object with the chs input
    pdsch = nrPDSCHConfig;
    dmrs = nrPDSCHDMRSConfig;
    pdsch = passign(chs,pdsch,'ReservedREs','ReservedRE');
    dmrs = passign(chs,dmrs,'PortSet','DMRSPortSet');
    numDMRSPorts = numel(dmrs.DMRSPortSet);
    if numDMRSPorts
        % Assign the number of layers to the number of DM-RS antenna ports
        pdsch.NumLayers = numDMRSPorts;
    else
        % Get the number of layers, when DM-RS antenna port set is empty
        pdsch = passign(chs,pdsch,'NLayers','NumLayers');
    end
    pdsch.Modulation = chs.Modulation;
    pdsch = passign(chs,pdsch,'PDSCHMappingType','MappingType');
    % Get SymbolAllocation value, depending on the values of SymbolSet
    % field
    if ~isfield(chs,'SymbolSet')
        pdsch.SymbolAllocation = [0 carrier.SymbolsPerSlot];
        ind = zeros(0,1);
    elseif isempty(chs.SymbolSet)
        pdsch.SymbolAllocation = [0 0];
        ind = zeros(0,1);
    else
        [lb,ub] = bounds(chs.SymbolSet);
        pdsch.SymbolAllocation = [lb ub-lb+1];
        symTemp = lb:ub;
        logicalMatrix = repmat(symTemp,numel(chs.SymbolSet),1) == repmat(chs.SymbolSet(:),1,pdsch.SymbolAllocation(2));
        ind = symTemp(~sum(logicalMatrix,1))';
    end
    pdsch.PRBSet = chs.PRBSet;
    pdsch = passign(chs,pdsch,'VRBToPRBInterleaving');
    pdsch = passign(chs,pdsch,'VRBBundleSize');

    % Assign the value of DM-RS reference point to either PRBReferencePoint
    % property of pdsch or DMRSReferencePoint property of dmrs, based on
    % the presence of those properties
    if isprop(pdsch,'PRBReferencePoint')
        pdsch = passign(chs,pdsch,'PRBRefPoint','PRBReferencePoint');
    else
        refPoint = 0;
        if isfield(chs,'PRBRefPoint')
            refPoint = chs.PRBRefPoint;
        end
        if refPoint == 0
            dmrs.DMRSReferencePoint = 'PRB0';
        else
            dmrs.DMRSReferencePoint = 'CRB0';
        end
    end

    pdsch = passign(chs,pdsch,'RNTI');

    % Assign the non-contiguous OFDM symbol indices that are not present in
    % SymbolSet field values, as one reserved PRB pattern
    if any(ind)
        pdsch.ReservedPRB{1}.PRBSet = pdsch.PRBSet;
        pdsch.ReservedPRB{1}.SymbolSet = ind;
        pdsch.ReservedPRB{1}.Period = [];
    end

    % Assign the values of field Reserved to property ReservedPRB
    if isfield(chs,'Reserved')
        for i = 1:numel(chs.Reserved)
            % Get the reserved pattern for the current processing slot
            reservedPRB = chs.Reserved(i);
            reservedSlots = floor(reservedPRB.Symbols/carrier.SymbolsPerSlot);
            if isfield(reservedPRB,'Period') && ~isempty(reservedPRB.Period)
                reservedPeriod = reservedPRB.Period;
            else
                reservedPeriod = 0;
            end
            % Find reserved symbol locations present in current slot
            selectedSymbols = find(reservedSlots == mod(carrier.NSlot,reservedPeriod));
            if ~isempty(selectedSymbols)
                % Assign the reserved pattern to reserved configuration
                % object and pdsch object, only if the current slot has a
                % reserved PRB pattern
                reservedObj = nrPDSCHReservedConfig;
                if ~iscell(reservedPRB.PRB)
                    % For non-cell array processing of PRB field, append
                    % one reserved configuration object to ReservedPRB
                    % property of pdsch object, for each reservedPRB
                    % structure
                    reservedObj.PRBSet = reservedPRB.PRB(reservedPRB.PRB>=0);
                    reservedObj.SymbolSet = reservedPRB.Symbols(selectedSymbols);
                    reservedObj.Period = reservedPRB.Period;
                    pdsch.ReservedPRB{end+1} = reservedObj;
                else
                    % For cell array processing of PRB field, each symbol
                    % can have different reserved PRB locations
                    % Append one reserved configuration object to
                    % ReservedPRB property of pdsch object, for each symbol
                    % that has reserved pattern in current slot
                    for j = 1:numel(selectedSymbols)
                        if length(reservedPRB.PRB) ~= length(reservedPRB.Symbols)
                            error('Symbol-wise reserved PRB resources (defined in a cell array) and associated symbols should have the same number of elements.');
                        end
                        tmp = reservedPRB.PRB{selectedSymbols(j)};
                        reservedObj.PRBSet = tmp(tmp>=0);
                        reservedObj.SymbolSet = reservedPRB.Symbols(selectedSymbols(j));
                        reservedObj.Period = reservedPRB.Period;
                        pdsch.ReservedPRB{end+1} = reservedObj;
                    end
                end
            end
        end
    end

    % Set DM-RS parameters
    dmrs.DMRSConfigurationType = chs.DMRSConfigurationType;
    dmrs = passign(chs,dmrs,'DMRSTypeAPosition');
    dmrs = passign(chs,dmrs,'DMRSAdditionalPosition');
    dmrs = passign(chs,dmrs,'DMRSLength');
    dmrs = passign(chs,dmrs,'DMRSSymbolSet','CustomSymbolSet');
    dmrs.NIDNSCID = chs.NIDNSCID;
    if isempty(dmrs.NIDNSCID)
        % Assign NIDNSCID with physical layer cell identity NCellID, when
        % NIDNSCID field is not present or is empty
        dmrs.NIDNSCID = carrier.NCellID;
    end
    dmrs.NSCID = chs.NSCID;
    % Get the value of NumCDMGroupsWithoutData property depending on the
    % value of field NumCDMGroupsWithoutData
    if isfield(chs,'NumCDMGroupsWithoutData') && ~isempty(chs.NumCDMGroupsWithoutData) ...
            && chs.NumCDMGroupsWithoutData
        dmrs.NumCDMGroupsWithoutData = chs.NumCDMGroupsWithoutData;
    else
        % Assign the value to 1, when the field NumCDMGroupsWithoutData is
        % not present, empty, or zero
        dmrs.NumCDMGroupsWithoutData = 1;
    end
    pdsch.DMRS = dmrs;

    % Set PT-RS parameters
    pdsch = passign(chs,pdsch,'EnablePTRS');
    ptrs = nrPDSCHPTRSConfig;
    ptrs = passign(chs,ptrs,'PTRSTimeDensity','TimeDensity');
    ptrs = passign(chs,ptrs,'PTRSFrequencyDensity','FrequencyDensity');
    ptrs = passign(chs,ptrs,'PTRSREOffset','REOffset');
    ptrs = passign(chs,ptrs,'PTRSPortSet');
    pdsch.PTRS = ptrs;

    % Disable PT-RS
    if (isfield(chs,'PTRSFrequencyDensity') && isempty(chs.PTRSFrequencyDensity))...
            || (isfield(chs,'PTRSTimeDensity') && isempty(chs.PTRSTimeDensity))
        pdsch.EnablePTRS = 0;
    end

end

function o = passign(s,o,f,p)

    if isfield(s,f) && ~isempty(s.(f))
        if nargin == 3
            o.(f) = s.(f);
        else
            o.(p) = s.(f);
        end
    end

end

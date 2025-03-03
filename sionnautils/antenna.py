import numpy as np
import tensorflow as tf
import sionna as sn

class PatternInterpGrid(object):
    """
    Describes an antenna pattern from a discrete set of points in the angular space
    and interpolates.  The data is assumed to be uniformly sampled in the angular space.
    """

    def __init__(self, Ev, Eh, phi_range=None, theta_range=None, dtype_real=tf.float64):
        """
        Parameters:
        -----------
        Ev:  (ntheta,nphi) tf.Tensor of dtype_complex or np.ndarray of complex values
            Complex E-field in the vertical polarization, where 
            `nphi` is the number of azimuth angles and `ntheta` is the number of elevation angles
        Eh:  (ntheta,nphi) tf.Tensor of dtype_complex or np.ndarray of complex values
            Complex E-field in the horizontal polarization.
        theta_range: (2,) tf.Tensor of dtype_real
            Inclination angle range in radians.  Default is `[0, pi]`
        phi_range: (2,) tf.Tensor of dtype_real
            Azimuth angle range in radians.  Default is `[0, 2*pi]`
        dtype_real: tf.dtype
            Data type of the real data.  The complex data is set accordingly.
            Default is tf.float64
        """

        # Set the data type
        self.dtype_real = dtype_real
        if dtype_real == tf.float64:
            self.dtype_complex = tf.complex128
        elif dtype_real == tf.float32:
            self.dtype_complex = tf.complex64
        else:
            raise ValueError("Data type must be tf.float32 or tf.float64")

        # Set the data
        self.Evgrid = Ev
        self.Ehgrid = Eh

        # Set the default ranges
        if phi_range is None:
            phi_range = tf.constant([0, 2*np.pi],dtype=self.dtype_real)
        self.phi_range = phi_range
        if theta_range is None:
            theta_range = tf.constant([0, np.pi],dtype=self.dtype_real)
        self.theta_range = theta_range

        # Conver the data to TensorFlow tensors if they are numpy arrays
        if isinstance(self.Evgrid, np.ndarray):
            self.Evgrid = tf.constant(self.Evgrid, dtype=self.dtype_complex)
        if isinstance(self.Ehgrid, np.ndarray):
            self.Ehgrid = tf.constant(self.Ehgrid, dtype=self.dtype_complex)

        # Check that the data are tensorflow tensors
        if not isinstance(self.Ehgrid, tf.Tensor)\
            or not isinstance(self.Evgrid, tf.Tensor):
            raise ValueError("The data Ev and Eh must be TensorFlow tensors or numpy arrays")

        # Get dimensions of the data
        self.ntheta, self.nphi = tf.shape(self.Evgrid)

        # Check that the data are the same size
        if self.Evgrid.shape != self.Ehgrid.shape:
            raise ValueError("The data Ev and Eh must have the same shape")

        # Pre-compute the scaling factors for the interpolation
        # These are cast to float32  
        self.stheta = tf.cast(self.ntheta-1, self.dtype_real)/\
            tf.cast(self.theta_range[1] - self.theta_range[0], self.dtype_real)
        self.sphi = tf.cast(self.nphi-1, self.dtype_real)/\
            tf.cast(self.phi_range[1] - self.phi_range[0], self.dtype_real)

    @tf.function
    def pattern(self, theta, phi):
        """
        Interpolates the antenna data at the given angles

        Parameters:
        -----------
        theta: (m,) tf.Tensor of dtype_float
            Inclination angle in radians where `m` is the number of points
        phi: (m,) tf.Tensor of dtype_float
            Azimuth angle in radians

        Returns:
        --------
        Ev: (m,) tf.Tensor of dtype_complex
            Complex E-field in the vertical polarization
        Eh: (m,) tf.Tensor of dtype_complex
            Complex E-field in the horizontal polarization
        """

        theta = tf.cast(theta, self.dtype_real)
        phi = tf.cast(phi, self.dtype_real)

        pi = tf.constant(np.pi, dtype=self.dtype_real)

        I = tf.cast(theta > pi, self.dtype_real)
        theta = (1-2*I)*theta + I*2*pi
        phi = phi + I*pi

        I = tf.cast(phi < 0, self.dtype_real)
        phi = phi + 2*pi*I

        # Find index of the closest elevation angle
        itheta = tf.cast(self.stheta*(theta - self.theta_range[0]), tf.int32)
        itheta = tf.clip_by_value(itheta, 0, self.ntheta-1)

        # Find index of the closest azimuth angle
        iphi = tf.cast(self.sphi*(phi - self.phi_range[0]), tf.int32)
        iphi = tf.clip_by_value(iphi, 0, self.nphi-1)

        # get the values of the E-field at the closest indices
        Ev = tf.gather_nd(self.Evgrid, tf.stack([itheta, iphi], axis=-1))
        Eh = tf.gather_nd(self.Ehgrid, tf.stack([itheta, iphi], axis=-1))

        return Ev, Eh
    
@tf.function
def cart_to_sph(X):
    """
    Cartesian to spherical coordinates

    Parameters
    ----------
    X : (nx, 3) tf.Tensor of dtype_float
        Coordinates in Cartesian space

    Returns
    -------
    r : (nx,) tf.Tensor of dtype_float
        Radius
    theta : (nx,) tf.Tensor of dtype_float
        Inclination angle in radians
    phi : (nx,) tf.Tensor of dtype_float
        Azimuth angle in radians
    """
    r = tf.sqrt(tf.reduce_sum(tf.square(X), axis=1))  # Radius
    phi = tf.atan2(X[:, 1], X[:, 0])  # Azimuthal angle
    theta = tf.acos(X[:, 2] / r)  # Polar angle

    return r, theta, phi

@tf.function
def sph_to_cart(r, theta, phi):
    """
    Spherical to Cartesian coordinates

    Parameters
    -------
    r : (nx,) tf.Tensor of dtype_float
        Radius
    theta : (nx,) tf.Tensor of dtype_float
        Inclination angle in radians
    phi : (nx,) tf.Tensor of dtype_float
        Azimuth angle in radians

    Returns
    ----------
    X : (nx, 3) tf.Tensor of dtype_float
        Coordinates in Cartesian space
    """
    x = r * tf.sin(theta) * tf.cos(phi)
    y = r * tf.sin(theta) * tf.sin(phi)
    z = r * tf.cos(theta)
    X = tf.stack((x, y, z), axis=1)

    return X


@tf.function
def spatial_sig(rx, theta, phi, freq):
    """
    Computes the spatial signature of a signal arriving at the receiver

    Parameters
    ----------

    rx : sionna.rt.Receiver
        Receiver object
    theta : (npath,) tf.Tensor of dtype_float
        Inclination angle in radians of the paths
    phi : (npath,) tf.Tensor of dtype_float
        Azimuth angle in radians of the paths
    freq : float
        Frequency of the signal in Hz
    """
    # Compute the wavelength
    vc = sn.SPEED_OF_LIGHT
    lam = vc/freq

    # Get real data type
    scene = rx.scene
    if scene.dtype == tf.complex64:
        dtype = tf.float32
    else:
        dtype = tf.float64
    
    # Get unit vectors along directions of arrival (npath, 3)
    npath = tf.shape(theta)[0]
    r = tf.ones((npath,), dtype=dtype)
    U = sph_to_cart(r, theta, phi)
    
    # Get the rotated positions of the arrays
    # (nelem, 3)
    arr = scene.rx_array
    pos = arr.rotated_positions(rx.orientation)

    # Compute the phase of the signal and the resulting spatial signature
    phase = 2*sn.PI*tf.reduce_sum(U[None,:,:]*pos[:,None,:],\
                           axis=2)/lam
    sv = tf.complex(tf.cos(phase), tf.sin(phase))
    return sv
    


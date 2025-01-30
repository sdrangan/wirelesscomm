import numpy as np
import tensorflow as tf

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





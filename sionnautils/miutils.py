# -*- coding: utf-8 -*-
"""
miutils.py:  Mitsuba utilities
"""
import re
import mitsuba as mi
import numpy as np

class CoverageMapPlanner(object):
    """
    Class to plan coverage maps for a scene in Mitsuba
    """
    
    def __init__(self, scene, bldg_tol=1, grid_size=10, bbox=None):
        """
        Args:
            scene: mitsuba scene
                Scene to trace rays in
            bldg_tol: float
                Minimum distance between the max and min heights of objects
                to consider that a point has a building at that location.
                Value in meters
            grid_size: float
                Size of the grid in each dimension in meters
            bbox : float array of shape (4) | None
                Bounding box for the grid `[xmin, xmax, ymin, ymax]`.
                If `None` is specified, the bounding box is taken from 
                `scene.bbox()`.
        """
        self.scene = scene
        self.bldg_tol = bldg_tol
        self.grid_size = grid_size
        if bbox is None:
            b = self.scene.bbox()
            self.bbox = np.array([b.min.x, b.max.x, b.min.y, b.max.y])
        else:
            self.bbox = bbox
        

    def set_grid(self):
        """
        Create a grid of points on the scene's (x,y) bounding box

        Sets the following attributes:
        x, y: (nx,) and (ny,) arrays 
            x and y coordinates along each axis
        xgrid, ygrid: (ny,nx) 
            2D mesh grid of all the points 
        """
        self.x = np.arange(self.bbox[0], self.bbox[1], self.grid_size)
        self.y = np.arange(self.bbox[2], self.bbox[3], self.grid_size)
        self.nx = len(self.x)
        self.ny = len(self.y)
        self.xgrid, self.ygrid = np.meshgrid(self.x, self.y)
        
        self.yvec = self.ygrid.flatten()

 
    def compute_grid_attributes(self):
        """
        Compute various attributes of the points on the grid

        Sets:
        zmin_grid, zmax_grid: (ny,nx) arrays
            Min and max z coordinate of each grid point
        bldg_grid: (ny,nx) array
            True if the point has a building as defined
            by `zmax_grid - zmin_grid > bldg_tol`
        in_region: (ny,nx) array
            True if the point is within the region defined
            by having at least one building point on the left and righ
        """
      
        # Create vectors from the grid points
        xvec = self.xgrid.flatten()
        yvec = self.ygrid.flatten()

        # Trace from slightly the bottom of the scene
        z = self.scene.bbox().min.z-1
        npts = self.nx*self.ny
        p0 = mi.Point3f(xvec, yvec, z*np.ones(npts))
        directions = np.zeros((npts, 3))
        directions[:,2] = 1
        directions = mi.Vector3f(directions)
        ray = mi.Ray3f(p0, directions)
        si = self.scene.ray_intersect(ray)
        p = np.array(si.p)
        zmin = p[:,2]
        self.zmin_grid = zmin.reshape(self.xgrid.shape)


        # Trace from slightly above the top of the scene
        z = self.scene.bbox().max.z+1
        p0 = mi.Point3f(xvec, yvec, z*np.ones(npts))
        directions = np.zeros((npts, 3))
        directions[:,2] = -1
        directions = mi.Vector3f(directions)
        ray = mi.Ray3f(p0, directions)
        si = self.scene.ray_intersect(ray)
        p = np.array(si.p)
        zmax = p[:,2]
        self.zmax_grid = zmax.reshape(self.xgrid.shape)

        # Find the points that are outside
        self.bldg_grid = (self.zmax_grid - self.zmin_grid > self.bldg_tol)

        # Find the points that are within the region
        # This is defined as having a point in a building on the left and right
        mleft = np.maximum.accumulate(self.bldg_grid, axis=1)
        u = np.fliplr(self.bldg_grid)
        mright= np.maximum.accumulate(u, axis=1)
        mright = np.fliplr(mright)
        self.in_region = mleft & mright

def get_elevation(mi_scene, x, y):
    """
    Finds the elevation of the scene at the given points

    Args:
    -----
    mi_scene: mitsuba scene
        Scene to trace rays in
    x, y: (npts,) and (npts,) arrays 
        x and y coordinates 

    Returns:
    --------
    zmin, zmax: (npts,) arrays
        Min and max z coordinate of each point
    """

    if np.isscalar(x):
        x = np.array([x])
        y = np.array([y])
        scalar = True
    else:
        scalar = False

  
    # Trace from slightly below the bottom of the scene
    z = mi_scene.bbox().min.z-1
    npts = x.shape[0]
    p0 = mi.Point3f(x, y, z*np.ones(npts))
    directions = np.zeros((npts, 3))
    directions[:,2] = 1
    directions = mi.Vector3f(directions)
    ray = mi.Ray3f(p0, directions)
    si = mi_scene.ray_intersect(ray)
    p = np.array(si.p)
    zmin = p[:,2]


    # Trace from slightly above the top of the scene
    z = mi_scene.bbox().max.z+1
    p0 = mi.Point3f(x, y, z*np.ones(npts))
    directions = np.zeros((npts, 3))
    directions[:,2] = -1
    directions = mi.Vector3f(directions)
    ray = mi.Ray3f(p0, directions)
    si = mi_scene.ray_intersect(ray)
    p = np.array(si.p)
    zmax = p[:,2]

    # Convert back to scalar
    if scalar:
        zmin = zmin[0]
        zmax = zmax[0]
   
    return zmin, zmax
     
  
        

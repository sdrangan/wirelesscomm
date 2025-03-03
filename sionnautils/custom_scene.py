# -*- coding: utf-8 -*-
"""
Created on Wed Jan 29 15:43:00 2025

@author: sdran
"""

import importlib.resources as pkg_resources
from multiprocessing import Value
import os
from geopy.geocoders import Nominatim
from pyproj import Transformer
import numpy as np
import json
import sionnautils

def get_scene(scene_name='empty_scene'):
    """
    Gets the file path for a scene
    
    Args
    ----
    scence_name : str
        Name of the scene.  The list of available scenes can be obtained
        using list_scenes()

    Returns
    -------
    """
    rootdir = pkg_resources.files(sionnautils)
    scenedir = os.path.join(rootdir, 'custom_scenes')
    scenedir = os.path.join(scenedir, scene_name)
    scenepath = os.path.join(scenedir, 'scene.xml')
    
    # Check if scenepath exists
    if not os.path.exists(scenepath):
        err_msg = 'Scene file %s does not exist.  ' % scenepath
        err_msg += 'Use list_scenes() to get available scenes.'
        raise ValueError(err_msg)

    # Get the map data
    map_data_fn = os.path.join(scenedir, 'map_data.json')
    if os.path.exists(map_data_fn):
        with open(map_data_fn, 'r') as f:
            map_data = json.load(f)
    else:
        raise ValueError('Map data file %s does not exist' % map_data_fn)
    
    return scenepath, map_data

def list_scenes():
    """
    Lists the available scenes
    """
    rootdir = pkg_resources.files(sionnautils)
    scenedir = os.path.join(rootdir, 'custom_scenes')

    # Find the sub-directories in scenedir
    scenes = [d for d in os.listdir(scenedir) if os.path.isdir(os.path.join(scenedir, d))]

    
    return scenes

def generate_scene(address, data_dir, descr=None, size_x=1000, size_y=1000):
    """
    Generates a scene file for Mitsuba from a street address

    Args
    ----
    address : str
        Street address of the scene
        (e.g. '370 Jay St, Brooklyn, NY')
    data_dir : str
        Directory where the scene file is saved
    descr : str
        Description of the scene for the map data
    name : str
        Name of the scene. 
    size_x : float
        Size of the scene in the x-direction in meters
    size_y : float
        Size of the scene in the y-direction in meters  
    """

    if 1:
        # Initialize Nominatim geocoder
        geolocator = Nominatim(user_agent="wireless_class")

        # Geocode the address
        location = geolocator.geocode(address)
        if location is None:
            raise ValueError('Address %s not found' % address)

        # Get the latitude and longitude
        lat = location.latitude
        long = location.longitude

        # Get the bounding box for the scene
        r_earth = 6371000
        lat1 = lat - 360*(size_y/2)/(2*np.pi*r_earth)
        lat2 = lat + 360*(size_y/2)/(2*np.pi*r_earth)
        long1 = long - 360*(size_x/2)/(2*np.pi*r_earth*np.cos(lat*np.pi/180))
        long2 = long + 360*(size_x/2)/(2*np.pi*r_earth*np.cos(lat*np.pi/180))

    if 1:
        # Command to generate the scene
        cmd = 'scenegen  bbox %f %f %f %f --data-dir %s' %\
            (long1, lat1, long2, lat2, data_dir)
        print('Running command: %s' % cmd)
        os.system(cmd)

    # Save the data
    if descr is None:
        descr = address
    map_data = {
        'bbox_lat' : [lat1, lat2],
        'bbox_long' : [long1, long2],
        'address' : address,
        'descr' : descr}

    # Convert to JSON
    map_data_json = json.dumps(map_data)
    map_data_fn = os.path.join(data_dir, 'map_data.json')
    with open(map_data_fn, 'w') as f:
        f.write(map_data_json)



def lat_lon_to_xy(bbox_lat, bbox_lon, lat, long):
    """
    Finds the x-y location in meters from the center of the bounding box
    given the latitude and longitude of the bounding box and the location

    Args
    ----
    bbox_lat : (2,) array
        Latitude of the bounding box
    bbox_lon : (2,) array
        Longitude of the bounding box
    lat : float
        Latitude of the location
    long : float
        Longitude of the location

    Returns
    -------
    x : float
        x-coordinate in meters from the center of the bounding box
    y : float
        y-coordinate in meters from the center of the bounding box
    """
    
    cen_lat = np.mean(bbox_lat)
    cen_long = np.mean(bbox_lon)
    local_crs = f"+proj=aeqd +lat_0={cen_lat} +lon_0={cen_long} +datum=WGS84 +units=m"
    transformer = Transformer.from_crs("epsg:4326", local_crs, always_xy=True)

    x, y = transformer.transform(long, lat)

    return x, y
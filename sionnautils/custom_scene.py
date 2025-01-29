# -*- coding: utf-8 -*-
"""
Created on Wed Jan 29 15:43:00 2025

@author: sdran
"""

import importlib.resources as pkg_resources
import os
import sionnautils

def get_scene(scene_name='empty_scene'):
    """
    Gets the file path for a scene
    
    Args
    ----
    scence_name : str
        Name of the scene.  Right now, the only
        scene that is supported is 'empty_scene'
    """
    rootdir = pkg_resources.files(sionnautils)
    scenedir = os.path.join(rootdir, 'custom_scenes')
    scenefn = scene_name+'.xml'
    scenepath = os.path.join(scenedir, scenefn)
    
    if not os.path.exists(scenepath):
        raise ValueError('Scene file %s does not exist' 
                         % scenepath)
    
    return scenepath
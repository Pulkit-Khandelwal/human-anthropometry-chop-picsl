from medpy.io import load
import matplotlib.pyplot as plt
import matplotlib.cm as cm
from medpy.metric import binary
import glob
from skimage.transform import resize
import cv2
from PIL import Image
import numpy as np
import os
import os.path
import glob
import warnings
import shutil
import random
from scipy import ndimage
import SimpleITK as sitk
import nibabel as nib
from scipy.ndimage import map_coordinates, gaussian_filter
from skimage.measure import label
import scipy.misc

def Standardize(image):
    """
    zero-mean, unit standard deviation
    """
    eps=1e-6
    standardized_image = (image - np.mean(image)) / np.clip(np.std(image), a_min=eps, a_max=None)
    return standardized_image

def Normalize(image, min_value=0, max_value=1):
    """
    change the intensity range
    """
    value_range = max_value - min_value
    normalized_image = (image - np.min(image)) * (value_range) / (np.max(image) - np.min(image))
    normalized_image = normalized_image + min_value
    return normalized_image

def read_nifti(filepath_image, filepath_label=False):

    img = nib.load(filepath_image)
    image_data = img.get_fdata()

    try:
        lbl = nib.load(filepath_label)
        label_data = lbl.get_fdata()
    except:
        label_data = 0

    return image_data , img#, label_data, img

def save_nifti(image, filepath_name, img_obj=False):

    if img_obj:
        img = nib.Nifti1Image(np.float64(image), img_obj.affine, header=img_obj.header) #np.eye(4)
    else:
        img = nib.Nifti1Image(np.float64(image), np.eye(4)) #np.eye(4)

    nib.save(img, filepath_name)


def getLargestCC(segmentation):
    segmentation = segmentation*100
    labels = label(segmentation)
    assert( labels.max() != 0 ) # assume at least 1 CC
    largestCC = labels == np.argmax(np.bincount(labels.flat)[1:])+1
    return largestCC


def bbox2_3D(img):

    r = np.any(img, axis=(1, 2))
    c = np.any(img, axis=(0, 2))
    z = np.any(img, axis=(0, 1))

    rmin, rmax = np.where(r)[0][[0, -1]]
    cmin, cmax = np.where(c)[0][[0, -1]]
    zmin, zmax = np.where(z)[0][[0, -1]]

    return rmin, rmax, cmin, cmax, zmin, zmax


invivo_image = '/Users/pulkit/Desktop/segm4.nii.gz'
invivo_image, img_obj = read_nifti(invivo_image)

segm = invivo_image
segm[segm>0] = 1
segm[segm<=0] = 0

save_nifti(segm, '/Users/pulkit/Desktop/segm4_binary.nii.gz', img_obj)

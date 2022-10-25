# Human skull anthropometry project
#### Author: Pulkit Khandelwal
#### Last updated: 10/24/22
## We will go through the steps for prcoessing the MRI data and getting it ready for making measurements in mimics.
#### Note: You can find all the files in this GitHub repository itself. Note that the files here have hard-coded directories paths and subject lists. You can change those as per your requirements.

#### What do you need? Basic skills in shell scripting, ITK-SNAP.
- You should download ITK-SNAP from [here](http://www.itksnap.org/pmwiki/pmwiki.php).
- You also need the command line tool `c3d` which comes alomg with ITK-SNAP and can learn more about it [here](http://www.itksnap.org/pmwiki/pmwiki.php?n=Convert3D.Convert3D).
- Matlab
- I ran all the code on a mac.
- I had received the data from Dillan and Zach in the form of zip file as `SAyr3BF001.zip`. I take those kind of files and then apply the following steps:

## Step 1
Unzip the downloaded zip file in the form, for example,`SAyr3BF001.zip`. See the file `unzip_all_subjects.sh`. Download a sample zip file from [here](https://upenn.box.com/s/zbw8m7ttsscuq664ee512z33cre9eitd) to work through this tutorial.

## Step 2
Now you will see a lot of folders within the extracted folder. And most of these folders have a lot of dicom files. We will try tp find the correct folder which hhas the `T1w` image. Use this `convert_to_nifti.sh` script which will find the folder which has the `T1w` image and will then convert the `dicom` series into a usuable `nifti` file.

## Step 3
Once, you get one `nifti` file for each subject, then you are ready to create the template image in `nifti` format. Note that is a separate process which I will discuss in the `Template building`. Refer to that section and then continue to `Step 4`. For now, let's say that the created template image is named as `template.nii.gz`. Normalize the intensity range of the image `template.nii.gz` using `skull_norm.sh`.

## Step 4
Now, we can threshold the template image using `c3d` to obtain a binary skull iamge, let's name it as `template_binary.nii.gz`. Refer to the documentation for more [here](http://www.itksnap.org/pmwiki/pmwiki.php?n=Convert3D.Documentation) and described here:

```-thresh, -threshold: Binary thresholding
Syntax: -thresh <u1 u2 vIn vOut>

Thresholds the image, setting voxels whose intensity is in the range [u1,u2] to vIn and all other voxels to vOut. Values u1 and u2 are intensity specifications (see below). This means that you can supply values inf and -inf for u1 and u2 to construct a one-sided threshold. You can also specify u1 and u2 as percentiles.
c3d in.img -threshold -inf 128 1 0 -o out.img
c3d in.img -threshold 64 128 1 0 -o out.img
c3d in.img -threshold 20% 40% 1 0 -o out.img
```

Choose the `-threshold` as per your judgement by opening up the `template.nii.gz` image and then see the values above which you want to set it to foreground and the ones which you want to set as background.

## Step 5
Lastly, we need to convert the `template_binary.nii.gz` to a dicom series using the file `dicomwritevolume.m`. We need to convert it to a dicom series because that is the only format which `Mimics` likes.

First, read the image using `niftiread`. See documentation [here](https://www.mathworks.com/help/images/ref/niftiread.html).

```
V = niftiread('template_binary.nii.gz');
```

The, use the `dicomwritevolume.m` and run it as:
```VS = [1 1 1] % this the voxel spacing and send the correct ones for your image.
fname = '/path/to/some/folder/subject.zip'
dicomwritevolume(fname, V, VS)
```
You will then have the `/path/to/some/folder/subject.zip` file which has the `dicom` series. Now, you open that file in `mimics` and then do the measurements!

## Template building
Here, we will build the template using a bunch of `T1w` images in `1nifti` files. First, remember to normalize each of the images, that are being used to build the template, using the commands in `skull_norm.sh`.

- You also need to have `greedy` installed. See instrcutions and documentation [here]().
- You also need some bianaries in order to build the template. Get the binaries from this [box link](https://upenn.box.com/s/5zzhfo1jjcdtttzhjap8syx865kth5m4).
- You need the files in the folder `template_building_files` in the GitHub repository:
  - `manifest.csv`: here you provide the complete path to each of the inout image, and also assign a name to each image.
  - `flags.json`: here you can provide different options for the template to be built. For example. here we care about either if the template building proccess is intialized using the average of all the input image or whether a particular image actts as an intial template image.
  - `greedy_build_template.sh` is the main template building script using the greedy tool. Go through it to understand the algorithm but you should not edit this file. Lastly, `pybatch.sh` is a file so that you can run on clusters; again you do not need to edit this file. 


And then run the following command:
```
export PATH="/path/to/where/you/have/the/greedy/binaries/":$PATH

sh greedy_build_template.sh -p flags.json -i manifest.csv -o template_work
```
`template_work` is where all the logs and the final template will be stored.

References: Read the following paper to understandhow templates are generally built.
```
Unbiased diffeomorphic atlas construction for computational anatomy by Sarang Joshi, Brad Davis, Matthieu Jomier, Guido Gerig.
```

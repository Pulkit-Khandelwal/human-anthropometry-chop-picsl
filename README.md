# Human skull anthropometry project
#### Author: Pulkit Khandelwal
#### Lats updated: 10/24/22
## Here, we will go through the steps for prcoessing the MRI data and getting it ready for making measurements in mimics.
#### Note: You can find all the files in this GitHub repository itself. Note that the files here have hard-coded directories paths and subject lists. You can change those as per your requirements.

#### What do you need? Basic skills in shell scripting, ITK-SNAP.
- You should download ITK-SNAP from [here](http://www.itksnap.org/pmwiki/pmwiki.php).
- You also need the command line tool `c3d` which comes alomg with ITK-SNAP and can learn more about it [here](http://www.itksnap.org/pmwiki/pmwiki.php?n=Convert3D.Convert3D).
- I ran all the code on a mac.
- I had received the data from Dillan and Zach in the form of zip file as `SAyr3BF001.zip`. I take those kind of files and then apply the following steps:

## Step 1
Unzip the downloaded zip file of the form `SAyr3BF001` . See the file `unzip_all_subjects.sh`

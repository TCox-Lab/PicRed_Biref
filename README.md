# **CMM Lab - Picrosirius Red Birefringence Analyser (Total Area)**
### CMM Lab website [Homepage](http://matrixandmetastasis.com)
### CMM Lab GitHub [Homepage](http://www.github.com/tcox-lab)
---
**ImageJ / FIJI script to analyse and quantify picrosirius red stained sections imaged under polarising light microscopy.**  
_Requires ImageJ/FIJI 1.38m or above._  
_Tested working on Mac OSX 10.14 and above._  
_Tested working on Windows 10._

_Last updated: 30th Sept 2020._

**Citation:**  
Vennin C _et al. **Nature Communications**_ (2019)  
_CAF hierarchy driven by pancreatic cancer cell p53-status creates a pro-metastatic and chemoresistant environment via perlecan_  
doi: 10.1038/s41467-019-10968-6   
[Pubmed link](https://pubmed.ncbi.nlm.nih.gov/31406163/)

**Description:**  
The script wraps the threshold colour function (HSB Thresholding) into a loop that iterates through all of the defined images in a directory and sub-directories specified by the user.

_If using multiple sub-directories of images, please ensure that filenames are unique._

This script is designed to automate the quantification of HSB thresholded area of picrosirius red stained birefringent signal in the "Red-Orange, "Yellow" and "Green" channels in each image, outputting channel overlays and collated tabulated results.

The user can specify the precise thresholding values for analysis to separate the different channels, which roughly correspond to high (Red-Orange), medium (Yellow) and low (Green) density/bundling of collagen fibres.

**All processed images should be taken using identical acquisition parameters**

---
### Installation

Ensure you have ImageJ or FIJI (preferred) installed.
- ImageJ is available from [here](https://github.com/imagej/imagej).
- FIJI is available from [here](https://github.com/fiji/fiji).

Copy the `CMM_PR-BRF_Analyser.ijm` to the ImageJ/FIJI `plugins` directory.  

Restart ImageJ/FIJI.

The script should now appear in the Plugins Dropdown menu.

---
### Basic variables specified by the user include:

Upon launching, the script will ask for the following inputs:

- **File Type** - Specify input image file type (.tif .jpg etc.)*.
- **Brightness Threshold** - Ignore pixels below a certain threshold (_applied to the whole image prior to analysis_).
- **Output Image Resize** - Set % scaling factor of output images (_helps to reduce file size_).
- **Edit Hue Thresholds** (Enable/Disable) - Allows manual adjustment of threshold levels used and other advanced options.
- **Save Separate Channels** (Enable/Disable)- Saves the individual Red / Orange-Yellow / Green channels to separate files.
-**Enable Batch Mode** (Enable/Disable) - Runs the script silently (_faster_).
-**Launch Memory Monitor** (Enable/Disable) - Mainly for debugging.

_*Output files (if enabled) are saved in .png format. Avoid using input files in the .png format where possible._

---
### Advanced variables specified by the user (_if enabled_) include:
If enabled in the Basic Parameter window, the script will launch a second input window, allowing for customisation of colour channel thresholding, pre- and post-processing of the images:

- **Red Minimum** - HSB (H) Red-Orange Minimum value
- **Red Maximum** - HSB (H) Red-Orange Maximum value
- **Yellow Minimum** - HSB (H) Yellow Minimum value
- **Yellow Maximum** - HSB (H) Yellow Maximum value
- **Green Minimum** - HSB (H) Green Minimum value
- **Green Maximum** - HSB (H) Green Maximum value
- **Saturation Minimum** - HSB (S) Saturation Minimum value
- **Enhance Output Image Contrast** (Enable/Disable) - Enhance Brightness/Contrast of **_Output_** images only (_does NOT affect analysis_)
- **Brightness/Contrast Minimum** - Output image Brightness/Contrast Enhance (Minimum Value)
- **Brightness/Contrast Maximum** - Output image Brightness/Contrast Enhance (Maximum Value)
- **Image Pre-processing Enhance** (Enable/Disable) - Enhance Brightness/Contrast of **_Input_** Images (_**WILL** affect analysis_)
- **Image Pre-processing Brightness/Contrast Minimum** - Input image Brightness/Contrast Enhance (Minimum Value)
- **Image Pre-processing Brightness/Contrast Maximum** - Input image Brightness/Contrast Enhance (Maximum Value)

---
_**Once basic and advanced options have been chosen, you will be asked to specify the input directory containing the image files to be analysed**_

---
### Output Image files
The script can be set to output colour overlays of each of the quantified channels.  
This is especially useful in QC'ing outputs, and for visual representations such as figures.  

Each analysis will output a Red-Orange, Yellow, and Green overlay of the original image in `.png` format in the same directory as the original image.  
(_The original image always remains unchanged_)

---
### Output text files

The analysis will output three text files in the top level directory:  

1. `Parameters.txt` - Contains a list of all the parameters used in the analysis, along with a list of successfully analysed image files.  

2. `PR-BRF_RawResults.txt` - The absolute area values of the Red / Orange-Yellow and Green separated channels.

3. `PR-BRF_PercentResults.txt` - The % area values of the Red / Orange-Yellow and Green separated channels in relation to total birefringent signal

---

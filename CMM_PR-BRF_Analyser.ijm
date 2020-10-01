// #### CMM Lab PR-BRF Analyser (Total Area) ####
// #### CMM Lab website (www.matrixandmetastasis.com) ####
// #### CMM Lab GitHub (www.github.com/tcox-lab) ####

// This script is designed to automate the quantification of HSB thresholded area of picrosirus red birefringent signal in the "Red", "Orange-Yellow" and "Green" channels
// These ranges roughly correspond to high, medium and low density/bundling of collagen fibres
// The script will batch process entire folders including all sub-folders

// Script version number
ver = "2.20"
requires("1.38m");

// Create Date and Time stamps for the output files
MonthNames = newArray("Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec");
DayNames = newArray("Sun", "Mon","Tue","Wed","Thu","Fri","Sat");
getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
TimeString = "";
if (dayOfMonth<10) {TimeString = TimeString+"0";}
TimeString = TimeString+dayOfMonth+" "+MonthNames[month]+" "+year+" ";
if (hour<10) {TimeString = TimeString+"0";}
TimeString = TimeString+hour+":";
if (minute<10) {TimeString = TimeString+"0";}
TimeString = TimeString+minute;

// For cross-platform applicability
fs = File.separator;

// Close all currently open images
run("Close All");

// Setup variables for analysis
FiTy=".xxx"; // Input filetype
BrTh = 10; // Brightness minimum threshold
ReMin = 0; // HSB (H) Red Minimum
ReMax = 27; // HSB (H) Red Maximum
YeMin = 28; // HSB (H) Yellow Minimum
YeMax = 47; // HSB (H) Yellow Maximum
GrMin = 48; // HSB (H) Green Minimum
GrMax = 140; // HSB (H) Green Maximum
SaMin = 0; // HSB (S) Saturation Minimum
EnCon = 0; // Enhance Brightness/Contrast of Output images (Will NOT affect analysis)
BCMin = 0; // Output image Brightness/Contrast Enhance (Minimum Value)
BCMax = 255; // Output image Brightness/Contrast Enhance (Maximum Value)
EditHue = 0; // Enable editing of inputs
MemMon = 0; // Launch memory monitor (debugging)
ChanOut = 0; // Save separate output images
scale = 100; // Scale output images (to reduce filesize)
PreCon = 0; // Enhance Brightness/Contrast of Input Images (WILL affect analysis)
PreBCMin = 0; // Input image Brightness/Contrast Enhance (Minimum Value)
PreBCMax = 255; // Input image Brightness/Contrast Enhance (Maximum Value)
BaMod = 0; // Batch mode setting for silent processing

// Create Dialog window to accept user inputs
Dialog.create("CMM PicRed BRF Analyser Settings");
Dialog.addString("Specify File Type", FiTy);
Dialog.addNumber("Brightness Threshold:", BrTh);
Dialog.addNumber("Resize Output Images (%):", scale);
Dialog.addCheckbox("Edit Hue Thresholds [Advanced]", false);
Dialog.addCheckbox("Save Separate Channels [Slower]", true);
Dialog.addCheckbox("Enable Batch Mode", true);
Dialog.addCheckbox("Launch Memory Monitor [Debugging]", false);
Dialog.show();
FiTy = Dialog.getString();
BrTh = Dialog.getNumber();
scale = Dialog.getNumber();
Edit = Dialog.getCheckbox();
Out = Dialog.getCheckbox();
BaM = Dialog.getCheckbox();
Mem = Dialog.getCheckbox();
if (Edit==true) EditHue = 1;
if (Out==true) ChanOut = 1;
if (BaM==true) BaMod = 1;
if (Mem==true) MemMon = 1;

// If "Edit Hue Thresholds [Advanced]" selected, ask for channel separation inputs
if (EditHue==1){
	Dialog.create("Advanced Hue/Saturation Settings");
	Dialog.addMessage("Only change these settings\nif you know what you are doing");
	Dialog.addNumber("Red Hue Min:", ReMin);
	Dialog.addNumber("Red Hue Max:", ReMax);
	Dialog.addNumber("Yellow Hue Min:", YeMin);
	Dialog.addNumber("Yellow Hue Max:", YeMax);
	Dialog.addNumber("Green Hue Min:", GrMin);
	Dialog.addNumber("Green Hue Max:", GrMax);
	Dialog.addNumber("Saturation Minimum:", SaMin);
	Dialog.addCheckbox("Pre-process Contrast (alters analysis)", false);
	Dialog.addNumber("B/C Minimum:", PreBCMin);
	Dialog.addNumber("B/C Maximum:", PreBCMax);
	Dialog.addCheckbox("Enhance Contrast of Output Images (aesthetics only)", false);
	Dialog.addNumber("B/C Minimum:", BCMin);
	Dialog.addNumber("B/C Maximum:", BCMax);
	Dialog.show();
	ReMin = Dialog.getNumber();
	ReMax = Dialog.getNumber();
	YeMin = Dialog.getNumber();
	YeMax = Dialog.getNumber();
	GrMin = Dialog.getNumber();
	GrMax = Dialog.getNumber();
	SaMin = Dialog.getNumber();
	PreCont = Dialog.getCheckbox();
	PreBCMin = Dialog.getNumber();
	PreBCMax = Dialog.getNumber();  
	Cont = Dialog.getCheckbox();
	BCMin = Dialog.getNumber();
	BCMax = Dialog.getNumber();  
	if (Cont==true) EnCon = 1;   
	if (PreCont==true) PreCon = 1;
	}

// Clear Memory before starting and launch memory monitor if selected
run("Collect Garbage");
if (MemMon==1){
	doCommand("Monitor Memory...");
	}

// Ask user to select target directory --- Will recurse through ALL subdirectories too
setOption("JFileChooser", true); 
dir = getDirectory("Choose the Directory containing your images files to be analysed");

// Setup output windows to capture results
title1="Raw"; // Captures Raw BRF Signals
title2="Percent"; // Calculates % signal based of total Birefringence
run("Text Window...", "name="+title1);
print("[Raw]","CMM Lab PR-BRF Analyser (Total Area) v"+ver+" - Run Date: "+TimeString+"\n");
print("[Raw]","CMM Lab website (www.matrixandmetastasis.com)"+"\n");
print("[Raw]","CMM Lab GitHub (www.github.com/tcox-lab)"+"\n\n");
print("[Raw]", "Image"+"\t"+"All"+"\t"+"Red-Orange"+"\t"+"Yellow"+"\t"+"Green"+"\n");
run("Text Window...", "name="+title2);
print("[Percent]","CMM Lab PR-BRF Analyser (% Area) v"+ver+" - Run Date: "+TimeString+"\n");
print("[Percent]","CMM Lab website (www.matrixandmetastasis.com)"+"\n");
print("[Percent]","CMM Lab GitHub (www.github.com/tcox-lab)"+"\n\n");
print("[Percent]", "Image"+"\t"+"% Red-Orange"+"\t"+"% Yellow"+"\t"+"% Green"+"\n");

//Set batch mode to speed up processing
if (BaMod==1){
	setBatchMode(true);
	}
else {
	setBatchMode(false);
	}

// Generate list of files to process
count = 0;
countFiles(dir);
n = 0;
processFiles(dir);
function countFiles(dir) {
	list = getFileList(dir);
	for (i=0; i<list.length; i++) {
		if (endsWith(list[i], "/"))
		countFiles(""+dir+list[i]);
		else
		count++;
		}
	}
function processFiles(dir) {
	list = getFileList(dir);
	for (i=0; i<list.length; i++) {
		if (endsWith(list[i], "/"))
		processFiles(""+dir+list[i]);
		else {
			showProgress(n++, count);
			path = dir+list[i];
			processFile(path);
			}
		}
	}
function processFile(path) {
	if (endsWith(path, FiTy)) {
		open(path);

// Get file info 
		name=getTitle();
		fname=File.nameWithoutExtension; 
		String.copy(name);
		dir=getDirectory("image");
		run("Clear Results"); // Clear any previous results

// Get image dimensions and set rescaling sizes (default is no scaling [i.e. 100%])
		selectWindow(name);
		width = getWidth();
		height = getHeight();
		new_wid = (width/100)*scale;
		new_hei = (height/100)*scale;

// Pre-process Brightness/Contrast enhance - WILL AFFECT ANALYSIS
		if (PreCon==1){
			setMinAndMax(PreBCMin, PreBCMax);
			run("Apply LUT");
			}

// #### Detect "Red" Fibre signal ####
		selectWindow(name);
		min=newArray(3);
		max=newArray(3);
		filter=newArray(3);
		run("Duplicate...", "title=Red");
		selectWindow("Red");
		run("HSB Stack");
		run("Convert Stack to Images");
		selectWindow("Hue");
		rename("0");
		selectWindow("Saturation");
		rename("1");
		selectWindow("Brightness");
		rename("2");
		min[0]=ReMin;
		max[0]=ReMax;
		filter[0]="pass";
		min[1]=SaMin;
		max[1]=255;
		filter[1]="pass";
		min[2]=BrTh;
		max[2]=255;
		filter[2]="pass";
		for (i=0;i<3;i++){
			selectWindow(""+i);
			setThreshold(min[i], max[i]);
			run("Convert to Mask");
			if (filter[i]=="stop")  run("Invert");
			}
		imageCalculator("AND create", "0","1");
		imageCalculator("AND create", "Result of 0","2");
		for (i=0;i<3;i++){
			selectWindow(""+i);
			close();
			}
		selectWindow("Result of 0");
		close();
		selectWindow("Result of Result of 0");
		run("Set Measurements...", "area limit redirect=None decimal=0");
		setAutoThreshold("Default dark");
		setOption("BlackBackground", true);
		run("Convert to Mask");
		run("Measure");
		ReFib=getResult("Area", 0); // Raw "Red" signal area
		if (ChanOut==1){ // Save Red Output Image if selected, otherwise close
			selectWindow("Result of Result of 0");
			rename("OverRed");
			run("8-bit");
			imageCalculator("AND create", name, "OverRed");
			rename(name+"Red-Orange");
			if (EnCon==1){ // Enhance Output Image Brightness/Contrast (if selected) - solely aesthetics
				setMinAndMax(BCMin, BCMax);
				run("Apply LUT");
				}
			run("Size...", "width=new_wid height=new_hei constrain average interpolation=Bilinear"); // Resize Output Image before save (based on scaling factor)
			saveAs("PNG", dir+fname+"_1_Red-Orange.png");
			close();
			selectWindow("OverRed");
			close();
			}
		else{
			selectWindow("Result of Result of 0");
			close();
			}

// #### Detect "Orange-Yellow" Fibre Signal ####
		selectWindow(name);
		min=newArray(3);
		max=newArray(3);
		filter=newArray(3);
		run("Duplicate...", "title=Yel");
		selectWindow("Yel");
		run("HSB Stack");
		run("Convert Stack to Images");
		selectWindow("Hue");
		rename("0");
		selectWindow("Saturation");
		rename("1");
		selectWindow("Brightness");
		rename("2");
		min[0]=YeMin;
		max[0]=YeMax;
		filter[0]="pass";
		min[1]=SaMin;
		max[1]=255;
		filter[1]="pass";
		min[2]=BrTh;
		max[2]=255;
		filter[2]="pass";
		for (i=0;i<3;i++){
			selectWindow(""+i);
			setThreshold(min[i], max[i]);
			run("Convert to Mask");
			if (filter[i]=="stop")  run("Invert");
			}
		imageCalculator("AND create", "0","1");
		imageCalculator("AND create", "Result of 0","2");
		for (i=0;i<3;i++){
			selectWindow(""+i);
			close();
			}
		selectWindow("Result of 0");
		close();
		selectWindow("Result of Result of 0");
		run("Set Measurements...", "area limit redirect=None decimal=0");
		setAutoThreshold("Default dark");
		setOption("BlackBackground", true);
		run("Convert to Mask");
		run("Measure");
		YeFib=getResult("Area", 1);
		if (ChanOut==1){ // Save Orange-Yellow Output Image if selected, otherwise close
			selectWindow("Result of Result of 0");
			rename("OverYel");
			run("8-bit");
			imageCalculator("AND create", name, "OverYel");
			rename(name+"Yellow");
			if (EnCon==1){ // Enhance Output Image Brightness/Contrast (if selected) - solely for aesthetics
				setMinAndMax(BCMin, BCMax);
				run("Apply LUT");
				}
			run("Size...", "width=new_wid height=new_hei constrain average interpolation=Bilinear"); // Resize Output Image before save (based on scaling factor)
			saveAs("PNG", dir+fname+"_2_Yellow.png");
			close();
			selectWindow("OverYel");
			close();
			}
		else{
			selectWindow("Result of Result of 0");
			close();
			}

// #### Detect "Green" Fibre Signal ####
		selectWindow(name);
		min=newArray(3);
		max=newArray(3);
		filter=newArray(3);
		run("Duplicate...", "title=Gre");
		selectWindow("Gre");
		run("HSB Stack");
		run("Convert Stack to Images");
		selectWindow("Hue");
		rename("0");
		selectWindow("Saturation");
		rename("1");
		selectWindow("Brightness");
		rename("2");
		min[0]=GrMin;
		max[0]=GrMax;
		filter[0]="pass";
		min[1]=SaMin;
		max[1]=255;
		filter[1]="pass";
		min[2]=BrTh;
		max[2]=255;
		filter[2]="pass";	
		for (i=0;i<3;i++){
			selectWindow(""+i);
			setThreshold(min[i], max[i]);
			run("Convert to Mask");
			if (filter[i]=="stop")  run("Invert");
			}
		imageCalculator("AND create", "0","1");
		imageCalculator("AND create", "Result of 0","2");		
		for (i=0;i<3;i++){
			selectWindow(""+i);
			close();
			}
		selectWindow("Result of 0");
		close();
		selectWindow("Result of Result of 0");
		run("Set Measurements...", "area limit redirect=None decimal=0");
		setAutoThreshold("Default dark");
		setOption("BlackBackground", true);
		run("Convert to Mask");
		run("Measure");
		GrFib=getResult("Area", 2);
		if (ChanOut==1){ // Save Green Output Image if selected, otherwise close
			selectWindow("Result of Result of 0");
			rename("OverGre");
			run("8-bit");
			imageCalculator("AND create", name, "OverGre");
			rename(name+"Green");
			if (EnCon==1){ // Enhance Output Image Brightness/Contrast (if selected) - solely aesthetics
				setMinAndMax(BCMin, BCMax);
				run("Apply LUT");
				}
			run("Size...", "width=new_wid height=new_hei constrain average interpolation=Bilinear"); // Resize Output Image before save (based on scaling factor)
			saveAs("PNG", dir+fname+"_3_Green.png");
			close();
			selectWindow("OverGre");
			close();
			}
		else{
			selectWindow("Result of Result of 0");
			close();
			}
		selectWindow(name);
		close();
// #### End Colour Thresholding ####

// Calculate fibre percentages based on total birefringent signal
		AllFib=ReFib+YeFib+GrFib;
		GrPer=((100/AllFib)*GrFib);
		YePer=((100/AllFib)*YeFib);
		RePer=((100/AllFib)*ReFib);

// Output results to windows
		print("[Raw]",name+"\t"+AllFib+"\t"+ReFib+"\t"+YeFib+"\t"+GrFib+"\n");
		print("[Percent]", name+"\t"+RePer+"\t"+YePer+"\t"+GrPer+"\n");
		print(name);
		}
	}

// Save results to file
selectWindow("Raw");
saveAs("Text",dir+"PR-BRF_RawResults.txt"); // Raw birefringent signal (Area)
run("Close");
selectWindow("Percent");
saveAs("Text",dir+"PR-BRF_PercentResults.txt"); // % Colour of Total birefringent signal
run("Close");
selectWindow("Results");
run("Close");

// Save an output file with the parameters used
title="Parameters";
run("Text Window...", "name="+title);
print("[Parameters]","CMM Lab PR-BRF Analyser (Area) v"+ver+" - Run Date: "+TimeString+"\n");
print("[Parameters]","CMM Lab website (www.matrixandmetastasis.com)"+"\n");
print("[Parameters]","CMM Lab GitHub (www.github.com/tcox-lab)"+"\n\n");
print("[Parameters]","File Type Used = "+FiTy+"\n\n");
print("[Parameters]","Brightness Threshold = "+BrTh+"\n\n");
print("[Parameters]","Red Min = "+ReMin+"\n");
print("[Parameters]","Red Max = "+ReMax+"\n");
print("[Parameters]","Yellow Min = "+YeMin+"\n");
print("[Parameters]","Yellow Max = "+YeMax+"\n");
print("[Parameters]","Green Min = "+GrMin+"\n");
print("[Parameters]","Green Max = "+GrMax+"\n");
print("[Parameters]","Saturation Min = "+SaMin+"\n");
print("[Parameters]","File Resize (%) = "+scale+"\n\n");
if (ChanOut==1){
	print("[Parameters]","Separate Channel outputs saved\n\n");
	}
if (PreCon==1){
	print("[Parameters]","Pre-Processing Brightness/Contrast Enhanced ("+PreBCMin+"/"+PreBCMax+")\n\n");
	}
if (EnCon==1){
	print("[Parameters]","Output Image Brightness/Contrast Enhanced ("+BCMin+"/"+BCMax+")\n\n");
	}
print("[Parameters]", "Files successfully analysed:\n\n");
print("[Parameters]", getInfo("log"));
selectWindow("Log");
run("Close");
selectWindow("Parameters");
saveAs("Text",dir+"Parameters.txt");
run("Close");

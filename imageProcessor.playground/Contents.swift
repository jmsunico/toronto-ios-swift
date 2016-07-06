// COURSERA - TORONTO - PEER GRADING ASSIGNMENT : INSTAFILTER PROCESSOR PLAYGROUND
// https://github.com/jmsunico/coursera-toronto-ios/tree/master/imageProcessor.playground
//
import UIKit
import XCPlayground

// We will start showing the source image provided
let image = UIImage(named: "sample")

// FAST SUMMARY OF REVIEWING CRITERIA

// 1. Does the playground code apply a filter to each pixel of the image? Maximum of 2 pts
//
// The file imageFilters.swift contains different functions that are applied to each pixel
//		of an image. All functions, but one helper (averaga RGBA calculation) have same
//		interface: they all require an UIImage as first parameter and an Int8 as a second
//		parameter (in some cases not used, as in "greyscale")to refine/graduate the filter 
//		behavior. Functions available are:
//			"Red channel modification": redChannel,
//			"Green channel": greenChannel,
//			"Blue channel": blueChannel,
//			"Alpha channel": alphaChannel,
//			"Bright": bright,
//			"Contrast": contrast,
//			"Greyscale": greyscale,
//			"Gamma correction": gammaCorrection,
//			"Scale": scale,  // Exclude this one from grading, as it is just built upon Libraries calls
//			"Color inversion": colorInversion,
//			"Solarisation": solarisation
//		Let's see some examples

solarisation(image!, degree: 50)
redChannel(image!, degree: 100)

// 2. Are there parameters for each filter formula that can change the intensity of the effect of the 
//		filter? Maximum of 3 pts
//
//		As mentioned, the 2nd parameter (in most functions) refine/graduate the filter behavior.
//		Let's see some examples, and compare to former ones:

solarisation(image!, degree: -100)
redChannel(image!, degree: -100)

// 3. Is there an interface to specify the order and parameters for an arbitrary number of filter
//		calculations that should be applied to an image? Maximum of 2 pts
//
//		The way this is implemented is by defining a "Workflow" class, that receives a sequence of 
//		filters to be applied: an array of tuples where first term is a String that identifies the
//		filter and the 2nd term an Int8 that describes the parameter. The String is not the name of 
//		the function, but a commodity name. The Workflow class contains a dictionary to obtain the
//		proper function name from this string.
//		This workflow defines just that: "a specific pipeline" ready to be applied to an image by
//		its internal "apply(image: UIImage)" method. Let's see an example:
//			3a. First we define the "pipeline"

var Enhance_Red_Then_Solarise = Workflow(withSequence:[("Red channel", 75), ("Solarisation", 75)])

//			3b. Then we can apply it to any image

if Enhance_Red_Then_Solarise != nil {
	Enhance_Red_Then_Solarise!.apply(image)
	Enhance_Red_Then_Solarise!.result
} else{
	print("Could not create pipeline")
}

//			3c. Now we check that order matters

var Solarise_Then_Enhance_Red = Workflow(withSequence:[("Solarisation", 75), ("Red channel", 75)])
if Solarise_Then_Enhance_Red != nil {
	Solarise_Then_Enhance_Red!.apply(image)
	Solarise_Then_Enhance_Red!.result
} else{
	print("Could not create pipeline")
}


// 4. Is there an interface to apply specific default filter formulas/parameters to an image, by 
//		specifying each configuration’s name as a String? Maximum of 2 pts
//
//		As seen this is indeed accomplished by defining these "pipelines", but I have incorporated
//		three improvements to allow pipelines combinations, and avoid using tuples:
//
//			4a. Operator '<<' allows combining (concatenating) pipeline's stages:

var red_down = Workflow(withSequence: [("Red channel", -50)])
var blue_up = Workflow(withSequence: [("Blue channel", -50)])

//				Which (should) give(s) the same result as:

var red_down_THEN_blue_up : Workflow

red_down_THEN_blue_up = red_down! << blue_up!

//				Indeed, we can check the stages upon a pipeline is built at any time:

red_down!.sequence
blue_up!.sequence

red_down_THEN_blue_up.sequence

//				And finally check that both methods give the very same result

if (red_down != nil) && (blue_up != nil){
	red_down!.apply(image)
	blue_up!.apply(red_down!.result)
	blue_up!.result
	red_down_THEN_blue_up.apply(image)
	red_down_THEN_blue_up.result
} else{
	print("Could not create pipeline")
}

//			4b. Workflow class initialiser allows ignoring not recognised commands
//				4bi. Let's see what happens if we misspell a filter

var turn_grayscale = Workflow(withSequence: [("Grayscale", 0), ("Solarisation", 50)])
if turn_grayscale != nil {
	print("Could create turn_greyscale pipeline")
	if turn_grayscale!.somethingWentWrong{
		print("...but there were some problems: check spelling...")
	}
	turn_grayscale!.sequence
	turn_grayscale!.apply(image)
	turn_grayscale!.result
		
		//				Not greycale, sure but we have a result because when the initialiser does not
		//				recognise a filter in one stage its substitues it by the "identity" filter,
		//				that returns the same image it was invoked with: in the console, an error message
		//				provides information. Above see that only solarisation stage is included
} else{
	print("Could not create pipeline")
}

//				4bii. Let's see the difference with the correct spelling
var turn_greyscale = Workflow(withSequence: [("Greyscale", 0), ("Solarisation", 50)])
if turn_greyscale != nil {
	print("Could create turn_greyscale pipeline")
	if turn_greyscale!.somethingWentWrong{
		print("...but there were some problems: check spelling...")
	}
	turn_greyscale!.sequence
	turn_greyscale!.apply(image)
	turn_greyscale!.result
	
	//				Now all 2 stages are included, as seen above.
} else{
	print("Could not create pipeline")
}

//				4c. Finally I have developed a first version of a bit more "natural inteface" to interact
//				with the Workflow class, that tokenises a string input and tries to extract filtering 
//				commands from it. Every filtering command must be separated by commas and then the name of
//				the filter (first token) and parameter by spaces. At the moment it only allows for one
//				Int8 parameter, so if different parameters are found, we only take the first valid one.
//				At the moment only type-checking is made, so the result will be an array of (String, Int8)
//				tuples. In the future I might expand this so I can check the required number and type of 
//				parameters that a function accepts and allow for that specific combination. If a valid String
//				is found, but not parameter is there, then the interface will expand this to include a 
//				default parameter.

//				Here is an example of the parsing and obtention of a type-correct array of tuples

var complextring = "   ,something,   greyscale 2 3  ,   Bright +50,   Greyscale,Scale 2,    , Contrast,,,  ,"
workflowInterface(complextring)

//			Then we just can initialise a pipeline with the result of this function.


var myPipeline = Workflow(withSequence: workflowInterface(complextring))

if myPipeline != nil {
	print("Could create turn_greyscale pipeline")
	if myPipeline!.somethingWentWrong{
		print("...but there were some problems: check spelling...")
	}
	myPipeline!.sequence
	myPipeline!.apply(image)
	myPipeline!.result
} else{
	print("Could not create pipeline")
}






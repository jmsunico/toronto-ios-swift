import UIKit

//Identity returns the exact image it is invoked with (mainly testing/coherency purposes)

public var functionsDictionary = [
	"Identity": identity,
	"Red channel": redChannel,
	"Green channel": greenChannel,
	"Blue channel": blueChannel,
	"Alpha channel": alphaChannel,
	"Bright": bright,
	"Contrast": contrast,
	"Greyscale": greyscale,
	"Gamma correction": gammaCorrection,
	"Scale": scale,
	"Color inversion": colorInversion,
	"Solarisation": solarisation
]

public func identity (source: UIImage, degree: Int8) -> UIImage{
	print("applying identity")
	return(source)
}

// Calculation of average RGBA values in source image
public func averageRGBA(source: RGBAImage) -> (Int, Int, Int, Int){
	let count = source.width * source.height
	var (reds, greens, blues, alphas) = (0,0,0,0)
	for y in 0..<source.height {
		for x in 0..<source.width {
			let index = y * source.width + x
			var pixel = source.pixels[index]
			(reds += Int(pixel.red), greens += Int(pixel.green), blues += Int(pixel.blue), alphas += Int(pixel.alpha))
		}
	}
	let average = (reds/count, greens/count, blues/count, alphas/count)
	print("Average RGBA values are \(average)")
	return average
}

//Red channel: increases DEGREE-1 times the distance from the average value
public func redChannel (source: UIImage, degree: Int8) -> UIImage{
	print("Adjusting red channel...")
	var myRGBA = RGBAImage(image: source)!
	let myRGBAaverage = averageRGBA(myRGBA)
	for y in 0..<myRGBA.height {
		for x in 0..<myRGBA.width {
			let index = y * myRGBA.width + x
			var pixel = myRGBA.pixels[index]
			let deltaRed = Int(pixel.red) - myRGBAaverage.0
			if deltaRed > 0{
				pixel.red = UInt8(max(0, min(255, myRGBAaverage.0 + deltaRed * Int(degree))))
				myRGBA.pixels[index] = pixel
			}
		}
	}
	print("Red channel adjusted!")
	return(myRGBA.toUIImage())!
}

//Green channel: increases DEGREE-1 times the distance from the average value
public func greenChannel (source: UIImage, degree: Int8) -> UIImage{
	print("Adjusting green channel...")
	var myRGBA = RGBAImage(image: source)!
	let myRGBAaverage = averageRGBA(myRGBA)
	for y in 0..<myRGBA.height {
		for x in 0..<myRGBA.width {
			let index = y * myRGBA.width + x
			var pixel = myRGBA.pixels[index]
			let deltaGreen = Int(pixel.green) - myRGBAaverage.1
			if deltaGreen > 0{
				pixel.green = UInt8(max(0, min(255, myRGBAaverage.1 + deltaGreen * Int(degree))))
				myRGBA.pixels[index] = pixel
			}
		}
	}
	print("Green channel adjusted!")
	return(myRGBA.toUIImage())!
}

//Blue channel: increases DEGREE-1 times the distance from the average value
public func blueChannel (source: UIImage, degree: Int8) -> UIImage{
	print("Adjusting blue channel...")
	var myRGBA = RGBAImage(image: source)!
	let myRGBAaverage = averageRGBA(myRGBA)
	for y in 0..<myRGBA.height {
		for x in 0..<myRGBA.width {
			let index = y * myRGBA.width + x
			var pixel = myRGBA.pixels[index]
			let deltaBlue = Int(pixel.blue) - myRGBAaverage.2
			if deltaBlue > 0{
				pixel.blue = UInt8(max(0, min(255, myRGBAaverage.2 + deltaBlue * Int(degree))))
				myRGBA.pixels[index] = pixel
			}
		}
	}
	print("Blue channel adjusted!")
	return(myRGBA.toUIImage())!
}

//Alpha channel: increases (DEGREE-1) times the transparency
public func alphaChannel (source: UIImage, degree: Int8) -> UIImage{
	print("Adjusting alpha channel...")
	var myRGBA = RGBAImage(image: source)!
	for y in 0..<myRGBA.height {
		for x in 0..<myRGBA.width {
			let index = y * myRGBA.width + x
			var pixel = myRGBA.pixels[index]
			if pixel.alpha > 0{
				pixel.alpha = UInt8(max(0, min(255, Int(pixel.alpha) * Int(degree))))
				myRGBA.pixels[index] = pixel
			}
		}
	}
	print("Alpha channel adjusted!")
	return(myRGBA.toUIImage())!
}

//Bright: Adjusts brightness by adding DEGREE to the value of each RGB component of the pixel
public func bright (source: UIImage, degree: Int8) -> UIImage{
	print("Adjusting bright...")
	var myRGBA = RGBAImage(image: source)!
	for y in 0..<myRGBA.height {
		for x in 0..<myRGBA.width {
			let index = y * myRGBA.width + x
			var pixel = myRGBA.pixels[index]
			pixel.red = UInt8(max(0, min(255, Int(pixel.red) + Int(degree))))
			pixel.green = UInt8(max(0, min(255, Int(pixel.green) + Int(degree))))
			pixel.blue = UInt8(max(0, min(255, Int(pixel.blue) + Int(degree))))
			myRGBA.pixels[index] = pixel
		}
	}
	print("Bright adjusted!")
	return(myRGBA.toUIImage())!
}

// Contrast: The formula is COLOR = 128+FACTOR*(COLOR-128))
// Where FACTOR is defined as (259*(2*DEGREE+255))/(255*(259-2*DEGREE))
public func contrast (source: UIImage, degree: Int8) -> UIImage{
	print("Adjusting contrast...")
	var myRGBA = RGBAImage(image: source)!
	let factor = Double(259.0 * (2*Double(degree) + 255.0)) / Double(255.0 * (259.0 - 2*Double(degree)))
	for y in 0..<myRGBA.height {
		for x in 0..<myRGBA.width {
			let index = y * myRGBA.width + x
			var pixel = myRGBA.pixels[index]
			pixel.red   = UInt8(max(0, min(255, 128.0 + factor * (Double(pixel.red) - 128.0))))
			pixel.green = UInt8(max(0, min(255, 128.0 + factor * (Double(pixel.green) - 128.0))))
			pixel.blue  = UInt8(max(0, min(255, 128.0 + factor * (Double(pixel.blue) - 128.0))))
			
			myRGBA.pixels[index] = pixel
		}
	}
	print("Contrast adjusted!")
	return(myRGBA.toUIImage())!
}


//Greyscale conversion: A recommended formula is "Red * 0.299 + Green * 0.587 + Blue * 0.114"
public func greyscale (source: UIImage, degree: Int8) -> UIImage{
	print("Generating a grayscale version of the image...")
	var myRGBA = RGBAImage(image: source)!
	for y in 0..<myRGBA.height {
		for x in 0..<myRGBA.width {
			let index = y * myRGBA.width + x
			var pixel = myRGBA.pixels[index]
			pixel.red = UInt8(Double(pixel.red) * 0.299 + Double(pixel.green) * 0.587 + Double(pixel.blue) * 0.114)
			pixel.green = pixel.red
			pixel.blue = pixel.red
			myRGBA.pixels[index] = pixel
		}
	}
	print("Greyscale version of the image generated!")
	return(myRGBA.toUIImage())!
}

//Gamma correction: A recommended formula is "COLOR=255*(COLOR/255)^(1/gamma)"
public func gammaCorrection (source: UIImage, degree: Int8) -> UIImage{
	print("Performing gamma correction of the image...")
	var myRGBA = RGBAImage(image: source)!
	let gammaCorrection = 1.0 / Double(degree)
	for y in 0..<myRGBA.height {
		for x in 0..<myRGBA.width {
			let index = y * myRGBA.width + x
			var pixel = myRGBA.pixels[index]
			pixel.red = UInt8(255 * pow(Double(pixel.red) / 255.0, gammaCorrection))
			pixel.green = UInt8(255 * pow(Double(pixel.green) / 255.0, gammaCorrection))
			pixel.blue = UInt8(255 * pow(Double(pixel.blue) / 255.0, gammaCorrection))
			myRGBA.pixels[index] = pixel
		}
	}
	print("Gamma correction performed!")
	return(myRGBA.toUIImage())!
}

//Color inversion (a particular type of "solarisation
public func colorInversion (source: UIImage, degree: Int8) -> UIImage{
	print("Performing color inverion...")
	let inverted = solarisation(source, degree: -128)
	print("Color inversion performed!")
	return(inverted)
}

//If COLOR > threshold => COLOR_SOLARISED = 255 - COLOR
public func solarisation (source: UIImage, degree: Int8) -> UIImage{
	print("Performing gamma correction of the image...")
	var myRGBA = RGBAImage(image: source)!
	for y in 0..<myRGBA.height {
		for x in 0..<myRGBA.width {
			let index = y * myRGBA.width + x
			var pixel = myRGBA.pixels[index]
			let threshold = UInt8(128 + Int(degree))
			
			if pixel.red > threshold{
				pixel.red = 255 - pixel.red
			}
			if pixel.green > threshold{
				pixel.green = 255 - pixel.green
			}
			if pixel.blue > threshold{
				pixel.blue = 255 - pixel.blue
			}
			myRGBA.pixels[index] = pixel
		}
	}
	print("Gamma correction performed!")
	return(myRGBA.toUIImage())!
}

// Scale an image
public func scale (source: UIImage, degree: Int8) -> UIImage{
	let newSize = CGSize(width: source.size.width  * CGFloat(degree), height: source.size.height * CGFloat(degree))
	let newRect = CGRectIntegral(CGRectMake(0,0, newSize.width, newSize.height))
	UIGraphicsBeginImageContextWithOptions(newSize, false, 0)
	let context = UIGraphicsGetCurrentContext()
	CGContextSetInterpolationQuality(context, .High)
	let flipVertical = CGAffineTransformMake(1, 0, 0, -1, 0, newSize.height)
	CGContextConcatCTM(context, flipVertical)
	CGContextDrawImage(context, newRect, source.CGImage)
	let newImage = UIImage(CGImage: CGBitmapContextCreateImage(context)!)
	UIGraphicsEndImageContext()
	return newImage
	
}

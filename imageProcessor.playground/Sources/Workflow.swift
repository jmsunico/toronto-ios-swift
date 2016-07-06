import UIKit

// Let's define a class for workflows that can be de a specific sequence of filters
// At the moment each instance will retain the result of each sequence of filters to easily
// visualise each workflow contribution, and pave the way to make workflows of workflows.

public class Workflow {
	public var somethingWentWrong = false

	public var sequence : [(String, Int8)] = [] // = [("Identity", 1)]
	public var result : UIImage?
	
	required public init? (withSequence: [(String, Int8)]){
		for index in 0..<withSequence.count {
			if  (functionsDictionary[withSequence[index].0] != nil){
				print("Valid tuple (filter, degree): (\(withSequence[index].0), \(withSequence[index].1))")
				self.sequence.append(withSequence[index])
			}
			else{
				self.somethingWentWrong = true
				print("Invalid tuple (filter, degree): (\(withSequence[index].0), \(withSequence[index].1))")
				print("Valid filters are:")
				for (key, _) in functionsDictionary{
					print("\t\"\(key)\"")
				}
			}
		}
	}
	
	public func apply(toSource: UIImage?) {
		self.result = toSource
		for index in 0..<sequence.count {
			self.result = functionsDictionary[self.sequence[index].0]!(self.result!, degree: self.sequence[index].1)
			
		}
	}
}

public func <<(left: Workflow, right: Workflow) -> Workflow {
	return Workflow(withSequence: left.sequence + right.sequence)!
}

public func workflowInterface(commandsSequenceString: String?) -> [(String, Int8)]{
	var commandsArray = commandsSequenceString!.componentsSeparatedByString(",")
	var sequence : [(String, Int8)] = []
	for i in 0..<commandsArray.count{
		commandsArray[i] = commandsArray[i].stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
		print("commandsArray[", i, "] = '", commandsArray[i], "'")
		if commandsArray[i] != "" {
			var tempArray = commandsArray[i].componentsSeparatedByString(" ")
			switch tempArray.count{
			case 0:
				print("No sense: research why I am here.")
			case 1:
				sequence.append((tempArray[0], Int8(1)))
				print("No parameters. Command extracted: ", sequence.last)
			default:
				for j in 1..<tempArray.count{
					if Int8(tempArray[j]) != nil {
						sequence.append((tempArray[0], Int8(tempArray[j])!))
						print("Found correct parameter = ", tempArray[j], ". Command extracted: ", sequence.last)
						break
					}
					else{
						if j == (tempArray.count - 1){
							sequence.append((tempArray[0], Int8(1)))
							print("End reached without (valid) parameters. Command extracted: ", sequence.last)
						}
					}
				}
			}
		}
		else{
			print("Ignoring empty command: commandsArray[", i, "] = '", commandsArray[i], "'")
		}
	}
	return sequence
}
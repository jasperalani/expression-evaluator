import os

fn main() {

	input_equation := os.input('Enter your equation: ')

	operations := ["*", "/", "+", "-"]
	numbers := ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]

	mut loop_operation := Operation{}

	tokens := gen_token_list(input_equation)

	println(tokens)

	exit(1)

	for index, token in tokens {
		
		if 0 == index && in_array(token, operations) {
			eprintln("First character cannot be an operation.")
			exit(1)
		}

		if !in_array(token, operations) {
			if !in_array(token, numbers) {
				eprintln("Character must be a number or one of: * / + -") 
				exit(1)
			}
		}

		if in_array(token, numbers) {

			if input_equation.len > 1 {

				mut left_build := token

				// loop through characters again and check if next one is a number
				for sub_index, _ in tokens[index..tokens.len-1] {
					if tokens.len-1 < sub_index+1 {
						break
					}
					sub_token := tokens[sub_index+1]
					if in_array(sub_token, operations) {
						break
					}
					println(sub_token)
					left_build += sub_token
				}

				loop_operation.left = left_build

			}
		}


		println(loop_operation)
	}
	
}

fn gen_token_list (input string) []string {
	mut tokens := []string{}
	for index, _ in input {
		tokens << input[index..index+1]
	}
	return tokens
}

fn in_array(needle string, haystack []string) bool {
	for _, item in haystack {
		if item == needle {
			return true
		}
	}

	return false
}

// Todo: Rename Operation struct to something different.
struct Operation {
	mut:
	token string
	token_index int

	left string
	right string
}
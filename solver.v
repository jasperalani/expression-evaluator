import os

fn main() {

	input_equation := os.input('Enter your equation: ')

	operations := ["*", "/", "+", "-"]
	numbers := ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]

	tokens := gen_token_list(input_equation)
	mut working_tokens_list := tokens.clone()

	mut terms := []Term{}
	mut working_term := Term{}

	mut used_term_indexes := []int{}

	mut used_index_offset := 0

	outer: for index, token in working_tokens_list {
		
		if 0 == index && in_array_str(token, operations) {
			eprintln("First character cannot be an operation.")
			exit(1)
		}
		
		if !in_array_str(token, operations) && !in_array_str(token, numbers) {
			eprintln("Equation can only contain numbers or one of: * / + -") 
			exit(1)
		}

		if in_array_int(index, used_term_indexes){
			continue
		}

		if 0 != index && in_array_str(token, operations) {
			working_term = Term{}
			working_term.tokens << token
			// term is complete, append to array
			terms << working_term
			// reset working term
			working_term = Term{}
			used_term_indexes << index
			used_index_offset++
			continue
		}

		if in_array_str(token, numbers) {

			working_term = Term{} 
			working_term.tokens << token

			if input_equation.len == 1 {
				continue
			}

			if index+1 > tokens.len {
				break
			}

			used_term_indexes << index
						
			// find the rest of the number
			for sub_index, sub_token in tokens[index+1..tokens.len] {

				if !in_array_str(sub_token, operations) {
					if used_term_indexes.len > 0 {
						used_term_indexes << used_term_indexes[used_term_indexes.len-1]+1
					}else{
						used_term_indexes << sub_index+1
					}
					working_term.tokens << sub_token
					continue
				}else{
					break
				}

			} 

			// term is complete, append to array
			terms << working_term
			// // reset working term
			working_term = Term{} 

		}

	}

	println(terms)
	
}

fn gen_token_list (input string) []string {
	mut tokens := []string{}
	for index, _ in input {
		tokens << input[index..index+1]
	}
	return tokens
}

fn in_array_str(needle string, haystack []string) bool {
	for _, item in haystack {
		if item == needle {
			return true
		}
	}

	return false
}

fn in_array_int(needle int, haystack []int) bool {
	for _, item in haystack {
		if item == needle {
			return true
		}
	}

	return false
}

struct Term {
	mut:
	tokens []string
}
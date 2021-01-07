import os
import strconv

struct Term {
	mut:
	tokens []string
	is_operator bool
}

struct Operation {
	mut:
	left int
	right int
	operator int
}

fn main() {

	input_equation := os.input('Enter your equation: ')

	terms := get_term_list(input_equation)

	operation_queue := gen_operation_queue(terms)

	result := execute_operation_queue(operation_queue)

	println(result)

}

fn execute_operation_queue (queue [][]Operation) f64 {
	mut op_output := 0.0

	// Execute operation queue
	for _, tier in queue {
		for op_index, operation in tier {

			match operation.operator {
				0 {
					if op_index == 0 {
						op_output = operation.left * operation.right
					}else{
						op_output = op_output * operation.right
					}
				}
				1 {
					op_output = op_output / operation.right
				}
				2 {
					op_output = op_output + operation.right
				}
				3 {
					op_output = op_output - operation.right
				}
				else {}
			}

		}
	}

	return op_output
}

fn gen_operation_queue(terms []Term) [][]Operation {

	mut tiered_operation_queue := [][]Operation{len: 2, init: []Operation{}}

	// Construct operation queue
	for index, term in terms {
		if !term.is_operator {
			continue
		}

		mut operator_index := 0
		mut operation_index := 0

		match term.tokens[0] {
			'/' {
				operator_index = 1
			}
			'+' {
				operator_index = 2
				operation_index = 1
			}
			'-' {
				operator_index = 3
				operation_index = 1
			}
			else {}
		}

		tiered_operation_queue[operation_index] << Operation{
			left: evaluate_numbers(terms[index-1].tokens)
			right: evaluate_numbers(terms[index+1].tokens)
			operator: operator_index
			}

	}

	return tiered_operation_queue

}

fn evaluate_numbers(tokens []string) int {
	mut return_number := 0
	for index, token in tokens {
		mut number := strconv.atoi(token) or {
			return 0
		}

		zeros := tokens.len - index
		for i := 0; i < zeros-1; i++ {
			number = number * 10
		}
		
		return_number += number
	}
	return return_number
}

fn get_term_list (equation string) []Term {
	operators := ["*", "/", "+", "-"]
	numbers := ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]

	tokens := gen_token_list(equation)
	mut working_tokens_list := tokens.clone()

	mut terms := []Term{}
	mut working_term := Term{}

	mut used_term_indexes := []int{}
	mut used_index_offset := 0

	outer: for index, token in working_tokens_list {
		
		if 0 == index && in_array_str(token, operators) {
			eprintln("First character cannot be an operation.")
			exit(1)
		}
		
		if !in_array_str(token, operators) && !in_array_str(token, numbers) {
			eprintln("Equation can only contain numbers or one of: * / + -") 
			exit(1)
		}

		if in_array_int(index, used_term_indexes){
			continue
		}

		if 0 != index && in_array_str(token, operators) {
			working_term = Term{}
			working_term.tokens << token
			working_term.is_operator = true
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

			if equation.len == 1 {
				continue
			}

			if index+1 > tokens.len {
				break
			}

			used_term_indexes << index
						
			// find the rest of the number
			for sub_index, sub_token in tokens[index+1..tokens.len] {

				if !in_array_str(sub_token, operators) {
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
			// reset working term
			working_term = Term{} 

		}

	} 

	return terms
}

fn gen_token_list (equation string) []string {
	mut tokens := []string{}
	for index, _ in equation {
		tokens << equation[index..index+1]
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
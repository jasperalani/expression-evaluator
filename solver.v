import os
import strconv

struct Term {
	mut:
	tokens []string
	is_operator bool
	precedence int
}

fn main() {

	input_equation := os.input('Enter your equation: ')

	terms := get_term_list(input_equation)

	postfix_notation := infix_to_postfix(terms)

	evaluated_answer := evaluate_postfix(postfix_notation)

	if evaluated_answer.stack.len > 0 {
		mut answer := evaluate_tokens(evaluated_answer.stack[0].tokens)
		
		// Cast int64 if number is an integer
		if i64(answer) == answer {
			println(i64(answer))
			exit(0)
		}

		println(answer)
	} else {
		println('error :P')
		exit(1)
	}

	exit(0)

}

/*** Stack ***/

struct Stack {
	mut:
	stack []Term
} 

fn (mut stack Stack) push (term Term) {
	if term.tokens.len == 0 {
		return
	}
	stack.stack << term
}

fn (mut stack Stack) pop () Term {
	if stack.stack.len > 0 {
		ret := stack.stack[stack.stack.len-1]
		stack.stack = stack.stack[0..stack.stack.len-1]
		return ret
	}
	return Term{}
}

fn (mut stack Stack) get_top () Term {
	if stack.stack.len > 0 {
		return stack.stack[stack.stack.len-1]
	}
	return Term{}
}

/******/

fn evaluate_postfix(stack Stack) Stack {
	mut oop_stack := Stack{}

	mut tmp1 := Term{}
	mut tmp2 := Term{}

	for _, term in stack.stack {
		if !term.is_operator {
			oop_stack.push(term)
		}else{
			tmp1 = oop_stack.pop()
			tmp2 = oop_stack.pop() 

			mut result := ""

			match term.tokens[0] {
				'*' {
					result = strconv.f64_to_str_l(evaluate_tokens(tmp1.tokens) * evaluate_tokens(tmp2.tokens))
				}
				'/' {
					result = strconv.f64_to_str_l(evaluate_tokens(tmp2.tokens) / evaluate_tokens(tmp1.tokens))
				}
				'+' {
					result = strconv.f64_to_str_l(evaluate_tokens(tmp1.tokens) + evaluate_tokens(tmp2.tokens))
				}
				'-' {
					result = strconv.f64_to_str_l(evaluate_tokens(tmp2.tokens) - evaluate_tokens(tmp1.tokens))
				}
				else {}
			}

			mut output := []string{}
			for _, rbyte in result {
				output << rbyte.ascii_str()
			}
			
			result_term := Term{
				tokens: output
			}

			// Push output of last evaluation to stack
			oop_stack.push(result_term)
		}
	}

	return oop_stack
}

fn infix_to_postfix(terms []Term) Stack {
	// Convert infix to postfix notation
	mut output := Stack{}
	mut operator_stack := Stack{}

	outer: for _, term in terms {
		if !term.is_operator {
			output.push(term)
		}else{
			// term is an operator		
			
			if operator_stack.stack.len == 0 {
				operator_stack.push(term)
				continue outer
			}

			for {
				top_of_stack := operator_stack.get_top()

				if term.precedence > top_of_stack.precedence {
					operator_stack.push(term)
					continue outer
				}

				if term.precedence == top_of_stack.precedence {
					output.push(operator_stack.pop())
					operator_stack.push(term)
					continue outer
				} 


				if term.precedence < top_of_stack.precedence {
					output.push(operator_stack.pop())
					continue
				}
			} 

		}
	}

	if operator_stack.stack.len > 0 {
		for _, _ in operator_stack.stack {
			output.push(operator_stack.pop()) 
		} 
	}

	return output
}

fn evaluate_tokens(tokens []string) f64 {

	// Find possibly existing decimal point
	if '.' in tokens {
		mut built_string := ""
		for _, s_token in tokens {
			built_string += s_token
		}
		return strconv.atof64(built_string)
	}

	// Working from left to right to create a number
	mut return_number := 0.0
	for index, token in tokens {
		mut number := strconv.atoi(token) or {
			return 0.0
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

	outer: for index, token in working_tokens_list {
		
		if 0 == index && token in operators {
			eprintln("First character cannot be an operation.")
			exit(1)
		}
		
		if !(token in operators) && !(token in numbers) {
			eprintln("Equation can only contain numbers or one of: * / + -") 
			exit(1)
		}

		if index in used_term_indexes {
			continue
		}

		if 0 != index && token in operators {
			working_term = Term{} 
			working_term.tokens << token
			working_term.is_operator = true
			working_term.precedence = 1
			match token {
				'/' { working_term.precedence = 1 }
				'+' { working_term.precedence = 0 }
				'-' { working_term.precedence = 0 }
				else {}
			}
			// term is complete, append to array
			terms << working_term
			// reset working term 
			working_term = Term{}
			used_term_indexes << index
			continue
		}

		if token in numbers {

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

				if !(sub_token in operators) {
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
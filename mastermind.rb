require 'pry-byebug'

class Game
    def initialize
        @player_name = "Bob"
        @board = Board.new
    end

    def play_game
        
    end

    # TODO: this method is too long and needs to be split up into smaller methods for readability
    def play_computer_guessing_game
        puts "Input a random 4-digit code for the computer to guess. Each digit is between 1-6"

        # while true
        #     puts "Enter code :"

        #     code_string = gets.chomp

        #     # Check for 4 digits. Does not check if entry is an integer
        #     if code_string.length == 4
        #         @board.user_defined_code(code_string)
        #         puts "Code #{code_string} stored"
        #         break
        #     end
        # end
        # @board.user_defined_code(code_string)
        @board.user_defined_code("5566")

        # @board.set_random_code
        p "Random code: #{@board.correct_code}"

        # start with three guesses: 1122, 3344, 5566
        starting_guesses = []
        starting_guesses.push(Guess.new("1122"))
        starting_guesses.push(Guess.new("3344"))
        starting_guesses.push(Guess.new("5566"))

        starting_guesses.each do |guess_object|
            correct_match = @board.check_guess(guess_object)
            @board.store_guess(guess_object)
            
            # For the off chance that the starting guesses are the correct code OR if there are too many starting guesses
            if correct_match
                @board.render_board
                puts "Computer guessed the code: #{@board.correct_code.join}"
                exit
            elsif @board.number_of_guesses >= 12
                @board.render_board
                puts "Computer ran out of guesses"
                exit
            end
        end

        
        # p @board.guess_history

        # look in feedback for all guesses
        # hard brackets [] -> number and position stored in known_code_array
        # soft brackets () -> add number to a probable_code_options array

        known_code_array = Array.new(4) {nil}
        probable_code_options = []
        guess_history = @board.guess_history

        guess_history.each do |guess|
            guess_array = guess.guess_array
            feedback_array = guess.feedback_array

            for i in 0...guess_array.length
                if feedback_array[i] == nil
                    next
                elsif feedback_array[i] == "[]"
                    known_code_array[i] = guess_array[i]
                    probable_code_options.push(guess_array[i]) # creates unnecessary guesses for some codes, but critical for codes like "1111"
                elsif feedback_array[i] == "()"
                    probable_code_options.push(guess_array[i])
                end
            end
        end

        # keep guessing using probable_code_options elements until a complete match ("[]") or run out of guesses
        # The current algorithm picks a random digit from an array of possible digits and is brute force. The algorithm wastes guesses by repeating digits in positions that haven't worked in the past. A smarter algorithm would store the positions of each soft equivalence "()" and ignore these positions for future guesses

        # TODO: Add processing of analyzing soft equivalence "()" to make the algorithm more intelligent
        while true

            # create a new guess based on known_code_array with "nil" entries replaced with random elements in probable_code_options
            # create a working copy of each array because a correct guess is not guaranteed
            temp_probable_code_options = probable_code_options.clone
            new_guess_array = known_code_array.clone

            new_guess_array.each_with_index do |digit, index|
                if digit == nil
                    # pick a random digit from the array of possible options
                    random_code_digit = temp_probable_code_options.sample

                    # try this random digit in the new guess
                    new_guess_array[index] = random_code_digit
                end
            end

            new_guess_string = new_guess_array.join
            new_guess_object = Guess.new(new_guess_string)


            # check if the new guess has already been checked. If so, generate a new guess
            matching_incorrect_guesses = @board.guess_history.select {|incorrect_guess| incorrect_guess.guess_array == new_guess_object.guess_array}
            unless matching_incorrect_guesses == []
                next
            end
            
            correct_match = @board.check_guess(new_guess_object)
            @board.store_guess(new_guess_object)

            # check feedback of created guess, does it have hard equivalence? If so update the known_code_array for the next iteration
            new_guess_guess_array = new_guess_object.guess_array
            new_guess_feedback_array = new_guess_object.feedback_array
            for j in 0...new_guess_guess_array.length
                if new_guess_feedback_array[j] == nil
                    next
                elsif new_guess_feedback_array[j] == "[]"
                    known_code_array[j] = new_guess_guess_array[j]
                end
            end

            if correct_match
                @board.render_board
                puts "Computer guessed the code: #{@board.correct_code.join}"
                break
            elsif @board.number_of_guesses >= 12
                @board.render_board
                puts "Computer ran out of guesses"
                break
            end
        end
    end

    def play_human_guessing_game
        
        # Generate a random code for the human to guess
        @board.set_random_code

        puts "Guess a random 4-digit code. Each digit is between 1-6"
 
        while true
            puts "Enter guess:"

            guess_string = gets.chomp

            # Check for 4 digits. Does not check if entry is an integer
            unless guess_string.length == 4
                puts "Incorrect number of digits"
                next
            end

            guess_object = Guess.new(guess_string)

            correct_match = @board.check_guess(guess_object)
            @board.store_guess(guess_object)
            @board.render_board

            if correct_match
                puts "Congratulations, you guessed the code: #{@board.correct_code.join}"
                break
            elsif @board.number_of_guesses >= 12
                puts "Rats! You ran out of guesses"
                break
            end
        end
    end
end

class Board
    attr_reader :correct_code
    attr_reader :guess_history
    attr_reader :feedback_history

    def initialize
        @correct_code = []
        @guess_history = []
        @feedback_history = [] # delete this if using @guess_history works out instead
    end

    # generate 4-digit random number with each digit between 1-6
    def set_random_code
        random_code = []
        
        4.times do
            random_code.push(rand(1..6))
        end

        @correct_code = random_code
    end

    def user_defined_code(code_string)
        # need to convert input to string, split into array of chars, then convert each element back to integer
        code_array = code_string.split("")
        code_array = code_array.map {|string| string = string.to_i}

        @correct_code = code_array
    end

    # return the number of guesses made
    def number_of_guesses
        @guess_history.length
    end

    def check_guess(guess_object)

        

        guess_array = guess_object.guess_array
        feedback_array = Array.new(4) {nil}
        unmatched_code_tally = @correct_code.tally # critical for pass #2, so that it ignores pass #1 matches
        
        # Pass #1: check for correct code AND correct position
        for i in 0...4
            
            if @correct_code[i] == guess_array[i]
                # puts "correct digit at position #{i+1}" #user readable position (1-4)
                feedback_array[i] = "[]"

                # remove one from the unmatched code tally to account for match
                unmatched_code_tally[guess_array[i]] -= 1
            end
        end

        # Pass #2: check for correct code AND wrong position from unchecked part of the code only
        for i in 0...4
            tally_result = unmatched_code_tally[guess_array[i]]
            
            # perform this check first to prevent a nil > 0 comparison below 
            if tally_result == nil
                next
            # skip digits that have already been marked by phase 1 (hard equivalence)
            elsif feedback_array[i] == "[]"
                next
            elsif tally_result > 0
                feedback_array[i] = "()"

                # remove one from the unmatched code tally to account for match
                unmatched_code_tally[guess_array[i]] -= 1
            end
        end

        guess_object.store_feedback(feedback_array)
        @feedback_history.push(feedback_array)

        # return true if a complete match is found
        if feedback_array == ["[]", "[]", "[]", "[]"] then true else false end
    end

    # store a guess in the history of guesses
    def store_guess(guess)
        @guess_history.push(guess)
    end

    # Display the history of guesses, feedback, legend and num guesses remaining
    def render_board
        puts ""
        puts "Guesses: "

        for i in 0...@guess_history.length do
            puts "#{i+1}: #{@guess_history[i].to_s}" #unsure why I need to write to_s, shouldnt this access the to_s method by default?
        end
        puts ""
        puts "Legend: "
        puts "[] = correct digit and position"
        puts "() = digit exists but incorrect position"
        puts ""
        puts "#{12-number_of_guesses} guesses remaining"
        puts ""
    end
end

class Guess
    attr_reader :guess_array
    attr_reader :feedback_array
    
    # accepts user input directly
    def initialize(guess_string)

        # need to convert input to string, split into array of chars, then convert each element back to integer
        guess_array = guess_string.split("")
        guess_array = guess_array.map {|string| string = string.to_i}
        @guess_array = guess_array

        @feedback_array = []
    end

    def store_guess(guess_array)
        @guess_array = guess_array
    end

    def store_feedback(feedback_array)
        @feedback_array = feedback_array
    end

    # Important function so Board#render_board works. @guess_array and @feedback_array are combined a simple way to display the result of a guess
    def to_s
        output_array = []

        for i in 0...guess_array.length
            unless feedback_array[i] == nil
                feedback_prefix = feedback_array[i][0,1]
                feedback_postfix = feedback_array[i][1,1]
                output = feedback_prefix + guess_array[i].to_s + feedback_postfix
                output_array.push(output)
            else
                output_array.push(" #{guess_array[i]} ")
            end
        end
        output_array.join(' ')
    end

    # helper function for finding bugs
    def debug
        "Guess: #{guess_array} Feedback: #{feedback_array}"
    end

end

while true do
a_game = Game.new
a_game.play_computer_guessing_game
end

# a_board = Board.new
# a_board.user_defined_code("6663")

# guess = Guess.new("5566")
# a_board.check_guess(guess)
# a_board.store_guess(guess)

# p guess.debug



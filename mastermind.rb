class Game
    def initialize
        @player_name = "Bob"
        @board = Board.new
    end

    def play_game
        puts "Guess the computer's 4-digit code. Each digit is between 1-6"
 
        @board.render_board
        while true
            
            
            puts "Enter guess:"

            guess_string = gets.chomp

            #check for correct input (4 digit integer only)
            unless guess_string.length == 4
                puts "Incorrect number of digits"
                next
            end

            guess = Guess.new(guess_string)


    
            @board.check_guess(guess)
            @board.store_guess(guess)
            @board.render_board
        end
    end
end

class Board
    def initialize
        #@correct_code = generate_random_code
        @correct_code = [1,2,3,4]
        @guesses = []
    end

    # generate 4-digit random number with each digit between 1-6
    def generate_random_code
        random_code = []
        
        4.times do
            random_code.push(rand(1..6))
        end

        random_code
    end


    def check_guess(guess)
        guess_array = guess.guess_array
        feedback_array = Array.new(4) {nil}
        remaining_unchecked_code = Array.new(4) {nil}
        
        # Pass #1: check for correct code AND correct position
        for i in 0...4
            if @correct_code[i] == guess_array[i]
                # puts "correct digit at position #{i+1}" #user readable position (1-4)
                feedback_array[i] = "[]"
            else
                remaining_unchecked_code[i] = guess_array[i]
            end
        end

        # # Pass #2: check for correct code AND wrong position
        # # ignore digits with correct code and position (Ignore matches from Pass #1)
        # for i in 0...4
        #     # skip digit in guess_array if digit is already correct AND correct position
        #     if feedback_array[i] == "[]"
        #         next
        #     elsif remaining_unchecked_code.any? {guess_array[i]}
        #         puts "digit at position #{i+1} exists but is in a wrong position"
        #         feedback_array[i] = "()"

        # end
    end

    def store_guess(guess)
        @guesses.push(guess)
    end

    # Number of guesses, feedback by 
    def render_board
        for i in 0...@guesses.length do
            puts "#{i+1}: #{@guesses[i].to_s}" #unsure why I need to write to_s, shouldnt this access the to_s method by default?
        end
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

    def to_s
        guess_array
    end

end

a_game = Game.new
a_game.play_game
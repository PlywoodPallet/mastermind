class Game
    def initialize
        @player_name = "Bob"
        @board = Board.new
    end

    def play_game
        puts "Guess the computer's 4-digit code. Each digit is between 1-6"
        puts "Enter first guess:"
        guess = gets.chomp.to_s
        guess_array = guess.split("")

        @board.check_guess(guess_array)
    end
end

class Board
    def initialize
        #@correct_code = generate_random_code
        @correct_code = [1,2,3,4]
        @guesses = []
    end

    # generate 4-digit random number. Each digit between 1-6
    def generate_random_code
        random_code = []
        
        4.times do
            random_code.push(rand(1..6))
        end

        random_code
    end


    def check_guess(guess_array)
        for i in 0..4
            if @correct_code[i] == guess_array[i].to_i then puts "correct code at position #{i}" end
        end
    end
end


# try to avoid using this class, might add some unnecessary complexity
class Guess
    def initialize
        @guess = []
        @feedback = []
    end

    def store_guess(guess_array)
        @guess = guess_array
    end

    def store_feedback(feedback_array)
        @feedback = feedback_array
    end
end

a_game = Game.new
a_game.play_game
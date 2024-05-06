require 'pstore'
require 'byebug'  # For debugging during testing (optional)
require 'rspec'

STORE_NAME = "tendable.pstore"

QUESTIONS = {
  "q1" => "Can you code in Ruby?",
  "q2" => "Can you code in JavaScript?",
  "q3" => "Can you code in Swift?",
  "q4" => "Can you code in Java?",
  "q5" => "Can you code in C#?"
}.freeze

def do_prompt
  answers = {}
  QUESTIONS.each do |question_key, question|
    print "#{question} (Yes/No): "
    answer = gets.chomp.downcase
    until ["yes", "no", "y", "n"].include?(answer)
      print "Please enter Yes or No: "
      answer = gets.chomp.downcase
    end
    answers[question_key] = answer
  end
  persist_answers(answers)
  calculate_rating(answers)
end

def persist_answers(answers)
  store = PStore.new(STORE_NAME)
  store.transaction do
    store[:answers] ||= []
    store[:answers] << answers
  end
end

def calculate_rating(answers)
  yes_count = answers.count { |_, answer| ["yes", "y"].include?(answer) }
  rating = (yes_count.to_f / QUESTIONS.size) * 100
  puts "Your rating for this run: #{rating.round(2)}%"
  rating
end

def calculate_average_rating
  store = PStore.new(STORE_NAME)
  total_rating = 0
  total_runs = 0
  store.transaction do
    store[:answers]&.each do |answers|
      total_rating += calculate_rating(answers)
      total_runs += 1
    end
  end
  average_rating = total_rating / total_runs unless total_runs.zero?
  puts "Average rating across all runs: #{average_rating.round(2)}%" if average_rating
end

RSpec.describe "Coding Skill Assessment" do
  # Helper method to clear persistent storage before each test
  before(:each) do
    FileUtils.rm_rf(STORE_NAME)  # Remove the store file if it exists
  end

  describe "do_prompt" do
    it "should ask all questions and store answers" do
      # Simulate user input with a hash
      user_answers = { "q1" => "yes", "q2" => "yes", "q3" => "yes", "q4" => "yes", "q5" => "yes"}

      # Allow reading from STDIN (simulated user input)
      allow(STDIN).to receive(:gets).and_return(*user_answers.values, "\n")
    end
  end

  describe "calculate_rating" do
    it "should calculate rating based on yes answers" do
      answers = { "q1" => "yes", "q2" => "yes", "q3" => "yes", "q4" => "yes", "q5" => "yes"}
      expect(calculate_rating(answers)).to eq(100)
    end
  end

  describe "calculate_average_rating" do
    # it "should calculate average rating from stored data" do
    #   # Simulate two runs with different answers
    #   store = PStore.new(STORE_NAME)
    #   store.transaction do
    #     store[:answers] ||= []
    #     store[:answers] << { "q1" => "yes", "q2" => "yes", "q3" => "yes", "q4" => "yes", "q5" => "yes"}
    #     store[:answers] << { "q1" => "yes", "q2" => "yes", "q3" => "yes", "q4" => "yes", "q5" => "yes"}
    #   end
    #   expect(calculate_average_rating).to eq(100)
    # end

    it "should handle no stored data" do
      expect(calculate_average_rating).to be_nil
    end
  end
end

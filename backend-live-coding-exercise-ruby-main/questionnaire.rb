require "pstore"
require 'byebug'

STORE_NAME = "tendable.pstore"

QUESTIONS = {
  "q1" => "Can you code in Ruby?",
  "q2" => "Can you code in JavaScript?",
  "q3" => "Can you code in Swift?",
  "q4" => "Can you code in Java?",
  "q5" => "Can you code in C#?"
}.freeze

def do_prompt
  answers = {} # Store answers for each and every question
  QUESTIONS.each do |question_key, question|
    print "#{question} (Yes/No): "
    answer = gets.chomp.downcase
    # Ensure the answer is either "yes" or "no"
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

do_prompt
calculate_average_rating

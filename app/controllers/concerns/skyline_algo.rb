# frozen_string_literal: true

module SkylineAlgo
  extend ActiveSupport::Concern

  # как избавиться от ошибки с разными хешами?????
  def choose_skyline (skylines, sprite_width)
    # лучший вариант - как можно ниже и как можно короче и как можно левее
    return nil if skylines.empty?
    best_skyline = nil
    if skylines[0].respond_to?(:stringify_keys)
      skylines = skylines.map(&:stringify_keys)
    end

    #current_skyline = skylines[0].dup

    # сортировка горизонтов от низшего к верхнему и получаение индексов элементов
    sorted_lines_ind = skylines.each_with_index.sort_by { |s, ind| s["start_height"] }.map { |pair| pair[1] }

    # поиск соседних горизонтов, которые были бы ниже и с которыми можно объединиться по ширине
    sorted_lines_ind.each do |i|
      line = skylines[i].dup

      # где-то не переназначается start_width

      # находим крайнюю точку левых соседей
      (i-1).downto(0) do |left_ind|
        if skylines[left_ind]["start_height"] <= line["start_height"]
          line["start_width"] = skylines[left_ind]["start_width"]
        else
          break
        end
      end

      # находим крайнюю точку правых соседей
      (i+1..skylines.size-1).each do |right_ind|
        if skylines[right_ind]["start_height"] <= line["start_height"]
          line["end_width"] = skylines[right_ind]["end_width"]
        else
          break
        end
      end
      line["width"] = line["end_width"] - line["start_width"]

      if line["width"] >= sprite_width
        return line
      end
    end


    nil
  end
end

class AtlasController < ApplicationController
  def index

  end

  # TODO создать здесь обработчики событий с атласами: добавление удаление
  # доюавление\ удаление присоединённого изображения
  # метод генерации изображения атласа по присоединённым изображениям (по вызову)
  # сначала просто склейка изображений подряд как в тестовой пробе
  # затем с использованием алгоритма какого-нибудь (полки)
  # заглушка под второй алгоритм
  # второй алгоритм (гильятина)

  def create
    user = User.find_by_id(params[:user_id])
    atlas = user.atlas.create(title: params[:title])

    if atlas
      if atlas.atlas_img.attach(
        io: File.open(Rails.root.join('public', 'images', 'transparent.png')),
        filename: 'atlas.png',
        content_type: 'image/png'
      )
        atlas.save
        render json: {
          atlas_id: atlas.id,
          title: params[:title],
          updated_at: atlas.updated_at,
          atlas_img: null
        }
      else
        render json: { errors: "Something went wrong while attaching image to atlas"}

      end
    else
      render json: { errors: "Something went wrong while creating new atlas" }
    end

  end

  def show_all # todo sort by recent update before send
    atlases = []
    if User.find_by_id(params[:user_id]).atlas.each do |atlas|
      atlases.push({
                     atlas_id: atlas.id,
                     title: atlas.title,
                     updated_at: atlas.updated_at,
                     atlas_img: url_for(atlas.atlas_img)
                   })
      end
      render json: { atlases: atlases }
    else
      render json: { errors: "Something went wrong while trying to find atlas" }
    end
  end

  def show
    atlas = User.find_by_id(params[:user_id]).atlas.find(params[:atlas_id])
    if atlas
      render json: {
        atlas_id: atlas.id,
        title: atlas.title,
        coords: atlas.coords,
        atlas_img: atlas.atlas_img
      }
    else
      render json: { errors: "Can't find atlas" }
    end
  end

  def delete
    atlas = User.find_by_id(params[:user_id]).atlas.find(params[:atlas_id])
    if atlas.destroy
      render json: { message: "Atlas successfully deleted." }
    else
      render json: { errors: "Something went wrong while deleting atlas" }
    end
  end

  # def create
  #   file1 = params[:img1]
  #   file2 = params[:img2]
  #
  #
  #   image11 = MiniMagick::Image.open(file1.file.path)
  #   image22 = MiniMagick::Image.open(file2.file.path)
  #
  #   width = [image11.width, image22.width].max
  #   height = image11.height + image22.height
  #
  #   # Создаем новое изображение с размерами, достаточными для склейки
  #   result_image = MiniMagick::Image.new("result.jpg") do |img|
  #     img.combine_options do |c|
  #       c.size "#{width}x#{height}"
  #       c.gravity "north"
  #       c.background "white"
  #       c.extent "#{width}x#{height}"
  #     end
  #   end
  #
  #   # Склеиваем изображения вертикально
  #   result_image = result_image.composite(image1) do |c|
  #     c.compose "Over"
  #     c.geometry "+0+0"
  #   end
  #
  #   result_image = result_image.composite(image2) do |c|
  #     c.compose "Over"
  #     c.geometry "+0+#{image1.height}"
  #   end
  #
  #   # Сохраняем результат во временный файл
  #   output_path = Rails.root.join("tmp", "combined_image.jpg")
  #   result_image.write(output_path)
  #
  #   # Отправляем результат клиенту
  #   send_file output_path, type: 'image/jpeg', disposition: 'inline'
  #
  #   file1.close
  #   file2.close
  #   File.delete(output_path) if File.exist?(output_path)
  # end
end
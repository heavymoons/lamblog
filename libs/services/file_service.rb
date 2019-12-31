# frozen_string_literal: true

module FileService
  module_function

  def list(dir = '')
    filelist = []
    dirlist = []
    files, dirs = S3Service.list(file_key(dir))
    filelist += files
    dirlist += dirs
    [filelist, dirlist]
  end

  def load(path)
    S3Service.load(file_key(path))
  end

  def save(path, data)
    S3Service.save_public(file_key(path), data)
  end

  def delete(path)
    S3Service.delete(file_key(path))
  end

  def mkdir(path)
    S3Service.save(file_key(path) + '/', '')
  end

  def key_base
    'files'
  end

  def file_key(dir = '')
    result = File.join(key_base, dir)
    result = result.gsub(/^\//, '')
    result
  end

end
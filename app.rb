#coding: utf-8
require 'bundler/setup'
Bundler.require
require "rubygems"
require 'sinatra/reloader' if development?
require "sinatra/activerecord"
require "fileutils"
require "securerandom"
require "zip"
require "./models"

enable :sessions

helpers do
    def first_directory(first,second,third)
        !(first.empty?) && second.empty? && third.empty?
    end
    def second_directory(first,second,third)
        !((first.empty?) || (second.empty?)) && third.empty?
    end
    def third_directory(first,second,third)
        !((first.empty?) || (second.empty?) || third.empty?)
    end
end

before /\/folders\/(\d*)\/?(\d*)\/?(\d*)\/?.*/ do |first,second,third|
    logger.info first
    logger.info second
    logger.info third
    unless session[:folder] == first.to_i
        redirect "/access"
    end
    if $download_done
        File.unlink("./public/temp.zip")
        $download_done = false
        p "delete done"
    end
end

get "/" do
    session[:folder] = nil
    erb :index
end

#folder_create
get "/create" do
    erb :create
end

post "/create_folder" do
    folder = VirtualFolder.create(
        name: params[:name],
        password: params[:password],
        password_confirmation: params[:password_confirmation]
    )
    if folder.valid?
        session[:folder] = folder.id
        redirect "/folders/#{session[:folder]}"
    else
        redirect "/create"
    end
end

post /\/folders\/(?:\d*\/)*(\d*)\/create_folder/ do
   child_folder = VirtualFolder.create!(
       name: params[:name],
       password: "child",
       password_confirmation: "child",
       virtual_folder_id: params[:captures][0]
    )
    
    redirect back
end

#access_folder
get "/access" do
   erb :access
end

post "/access_folder" do
    folder= VirtualFolder.find_by(name: params[:name])
    if folder && folder.authenticate(params[:password])
        session[:folder] = folder.id
        redirect "/folders/#{session[:folder]}"
    else
        redirect "/access"
    end
end

get /folders\/(\d*)\/?(\d*)\/?(\d*)\/?/ do |first,second,third|
    if first_directory(first,second,third)
        VirtualFolder.folder_request(first.to_i)
        erb :folder
    elsif second_directory(first,second,third)
        VirtualFolder.folder_request(second.to_i)
        erb :folder
    elsif third_directory(first,second,third)
        VirtualFolder.folder_request(third.to_i)
        @folder_limit = true
        erb :folder
    else
        redirect "/access"
    end
end

#folder_delete
post /\/folders\/(\d*)\/?(\d*)\/?(\d*)\/delete/ do |first,second,third|
    if first_directory(first,second,third)
        VirtualFolder.folder_delete(first.to_i)
        redirect "/"
    elsif second_directory(first,second,third)
        VirtualFolder.folder_delete(second.to_i)
        redirect "/folders/#{first}"
    elsif third_directory(first,second,third)
        VirtualFolder.folder_delete(third.to_i)
        redirect "/folders/#{first}/#{second}"
    else
        redirect back
    end
end

#file_upload
post /\/folders\/(\d*)\/?(\d*)\/?(\d*)\/?upload_file/ do |first,second,third|
    file = params[:file]
    if first_directory(first,second,third)
        VirtualFolder.file_upload(first.to_i,file)
    elsif second_directory(first,second,third)
        VirtualFolder.file_upload(second.to_i,file)
    elsif third_directory(first,second,third)
        VirtualFolder.file_upload(third.to_i,file)
    end
    redirect back
end

#file_delete
post /\/folders\/(?:\d*\/)*files\/(\d*)\/delete/ do |file_id|
   delete_file = VirtualFile.find(file_id.to_i)
   File.unlink("./public/#{delete_file.link}#{delete_file.filetype}")
   delete_file.destroy
   
   redirect back
end

#development_stage
=begin
get "/ziptest" do
    zipfile_name = "./public/testzip.zip"
    
    Zip::File.open(zipfile_name,Zip::File::CREATE) do |zipfile|
        zipfile.add("test.pdf","./public/3AHR最終原稿.pdf")
    end
    send_file(zipfile_name)
end
=end

post /\/folders\/(\d*)\/?(\d*)\/?(\d*)\/?download/ do |first,second,third|
    if first_directory(first,second,third)
        
    elsif second_directory(first,second,third)
    
    elsif third_directory(first,second,third)
        folder = VirtualFolder.find(third.to_i)
        files = folder.virtual_files
        zipfile_name = "./public/temp.zip"
        Zip::File.open(zipfile_name,Zip::File::CREATE) do |zipfile|
            files.each do |file|
                zipfile.add("#{file.name}","./public/#{file.link}#{file.filetype}")
            end
            
        end
    end
    $download_done = true

    send_file(zipfile_name,filename: folder.name+".zip")
    redirect "/folders/#{first}/#{second}/#{third}"
end


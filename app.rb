#coding: utf-8
require 'bundler/setup'
Bundler.require
require 'sinatra/reloader' if development?
require "sinatra/activerecord"
require "fileutils"
require "securerandom"
require "./models"

enable :sessions

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
        @folder = folder
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
        @folder = folder
        session[:folder] = folder.id
        redirect "/folders/#{session[:folder]}"
    else
        redirect "/access"
    end
end

get /\/folders\/(\d*)\/?(?:\d*\/)*(\d*)/ do
    if params[:captures][1] == ""
        requested_folder = VirtualFolder.find(params[:captures][0])
        if session[:folder] == requested_folder.id
            @folder = VirtualFolder.find(params[:captures][0])
            @childfolders = VirtualFolder.find(params[:captures][0]).virtual_folders
            @files = VirtualFolder.find(params[:captures][0]).virtual_files
            erb :folder
        end
    elsif params[:captures][1]
        parent_folder = VirtualFolder.find(params[:captures][0])
        if session[:folder] == parent_folder.id
            requested_folder = VirtualFolder.find(params[:captures][1])
            @folder = requested_folder
            @childfolders = requested_folder.virtual_folders
            @files = requested_folder.virtual_files
            erb :folder
        end
    else
        redirect back
    end
end

#folder_delete
post /\/folders\/(\d*)\/?(?:\d*\/)*(\d*)\/delete/ do
    if params[:captures][1] == ""
        delete_folder = VirtualFolder.find(params[:captures][0])
        delete_files = delete_folder.virtual_files
       delete_files.each do |delete_file|
            File.unlink("./public/#{delete_file.link}#{delete_file.filetype}")
        end
        delete_folder.destroy
        redirect "/"
    elsif params[:captures]
        delete_folder = VirtualFolder.find(params[:captures][1])
        delete_files = delete_folder.virtual_files
        delete_files.each do |delete_file|
            File.unlink("./public/#{delete_file.link}#{delete_file.filetype}")
        end
        delete_folder.destroy
        redirect "/folders/#{params[:captures][0]}"
    else
        redirect back
    end
end

#file_upload
post /\/folders\/(?:\d*\/)*(\d*)\/upload_file/ do
    folder = VirtualFolder.find(params[:captures][0])
    
    upload_file = params[:file]
    unless upload_file
        redirect back
    end
    tempfile = upload_file[:tempfile]
    folder.size += tempfile.size
    if folder.size <= 1073741824
        begin
            file = VirtualFile.create(
                name: upload_file[:filename],
                filetype: File.extname(upload_file[:filename]),
                link: SecureRandom.hex(8).to_s,
                virtual_folder_id: folder.id
            )
        rescue Errno::EEXIST
            retry
        end
        
        if file.valid?
            f = open("./public/#{file.link}#{file.filetype}", "w")
            f.write(tempfile.read)
            f.close
        else
            File.unlink(upload_file)
        end
        File.unlink(tempfile)
    end
    
    redirect back
end

#file_delete
post /\/folders\/(?:\d*\/)*files\/(\d*)\/delete/ do
    logger.info params[:captures]
   delete_file = VirtualFile.find(params[:captures][0])
   File.unlink("./public/#{delete_file.link}#{delete_file.filetype}")
   delete_file.destroy
   
   redirect back
end

#development_stage

#coding: utf-8
require 'bundler/setup'
Bundler.require
require "rubygems"
require 'sinatra/reloader' if development?
require "sinatra/activerecord"
require "fileutils"
require "securerandom"
require "zip"
require "date"
require "./models"

@@error = ""

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

get "/" do
    session[:master] = nil
    @@error = ""
    erb :index
end

#folder_create
get "/create" do
    @today = Date.today
    @expire_limit = @today + 1.week 
    erb :create
end

post "/create_folder" do
    folder = VirtualFolder.create(
        name: params[:name],
        password: params[:password],
        password_confirmation: params[:password_confirmation],
        expire: params[:date]
    )
    e = folder.errors.full_messages
    unless e.nil?
        @@error = e
    end
    
    if folder.valid?
        folder.root_id = folder.id
        folder.save
        session[:folder] = folder.id
        redirect "/folders/#{folder.id}"
    else
        redirect "/create"
    end
end

post "/folders/:id/create_folder/" do
    folder_id = params[:id].to_i
    
    VirtualFolder.create(
        name: params[:name],
        password: "child",
        password_confirmation: "child",
        virtual_folder_id: folder_id, #parent
        root_id: VirtualFolder.find(folder_id).root_id
    )
    
=begin
    if first_directory(first,second,third)
        folder_names = Array.new
        child_folders = VirtualFolder.find(first.to_i).virtual_folders
        child_folders.each_with_index do |folder,i|
            folder_names[i] = folder.name
        end
        unless folder_names.include?(params[:name])
            child_folder = VirtualFolder.create(
                name: params[:name],
                password: "child",
                password_confirmation: "child",
                virtual_folder_id: first.to_i
            )
        else
            @@error = "folder name already exists"
        end
    elsif second_directory(first,second,third)
        folder_names = Array.new
        child_folders = VirtualFolder.find(second.to_i).virtual_folders
        child_folders.each_with_index do |folder,i|
            folder_names[i] = folder.name
        end
        unless folder_names.include?(params[:name])
            child_folder = VirtualFolder.create(
                name: params[:name],
                password: "child",
                password_confirmation: "child",
                virtual_folder_id: second.to_i
            )
        else
           @@error = "folder name already exists"
        end
    end
=end
    redirect back
end

#access_folder
get "/access" do
   erb :access
end

post "/access_folder" do
    folder = VirtualFolder.find_by(name: params[:name])
    if folder && folder.authenticate(params[:password])
        session[:folder] = folder.id
        redirect "/folders/#{session[:folder]}"
    else
        @@error = "authenticate error"
        redirect "/access"
    end
end

get "/folders/:id" do
    folder_id = params[:id].to_i
    
    if VirtualFolder.find(folder_id).root_id != session[:folder]
        p session[:folder]
        p VirtualFolder.find(folder_id).root_id
        @@error = "not authenticated"
        redirect "/access"
    end
    
    @folder = VirtualFolder.find(folder_id) 
    if @folder.expire < Date.today
        redirect "/not_found"
    end
    
    @files = @folder.virtual_files
    @children = @folder.children
    
    erb :folder
end

#file_upload
post "/folders/:id/upload_file/" do
    folder_id = params[:id].to_i
    
    params[:files].each do |file|
        VirtualFolder.file_upload(folder_id,file)
    end
end

#download
post /\/folders\/(\d*)\/?(\d*)\/?(\d*)\/?download/ do |first,second,third|
    temp = SecureRandom.hex(8).to_s
    zipfile = "/tmp/temp_#{temp}.zip"
    if first_directory(first,second,third)
        folder = VirtualFolder.find(first.to_i)
        files = folder.virtual_files
        
        Zip::File.open(zipfile,Zip::File::CREATE) do |zip|
            files.each do |file|
                zip.add("#{file.name.encode("Shift_JIS")}","./public/uploaded/#{file.link}#{file.filetype}")
            end
            child_folders = folder.virtual_folders
            if child_folders
                child_folders.each do |child_folder|
                    zip.mkdir("#{child_folder.name.encode("Shift_JIS")}")
                    child_files = child_folder.virtual_files
                    child_files.each do |child_file|
                        zip.add("#{child_folder.name.encode("Shift_JIS")}/#{child_file.name.encode("Shift_JIS")}","./public/uploaded/#{child_file.link}#{child_file.filetype}")
                    end
                    grandchild_folders = child_folder.virtual_folders
                    if grandchild_folders
                        grandchild_folders.each do |grandchild_folder|
                            zip.mkdir("#{child_folder.name.encode("Shift_JIS")}/#{grandchild_folder.name.encode("Shift_JIS")}")
                            grandchild_files = grandchild_folder.virtual_files
                            grandchild_files.each do |grandchild_file|
                                zip.add("#{child_folder.name.encode("Shift_JIS")}/#{grandchild_folder.name.encode("Shift_JIS")}/#{grandchild_file.name.encode("Shift_JIS")}","./public/uploaded/#{grandchild_file.link}#{grandchild_file.filetype}")
                            end
                        end
                    end
                end
            end
        end
    elsif second_directory(first,second,third)
        folder = VirtualFolder.find(second.to_i)
        files = folder.virtual_files
        Zip::File.open(zipfile,Zip::File::CREATE) do |zip|
            files.each do |file|
                zip.add("#{file.name.encode("Shift_JIS")}","./public/uploaded/#{file.link}#{file.filetype}")
            end
            child_folders = folder.virtual_folders
            if child_folders
                child_folders.each do |child_folder|
                    zip.mkdir("#{child_folder.name.encode("Shift_JIS")}")
                    child_files = child_folder.virtual_files
                    child_files.each do |child_file|
                        zip.add("#{child_folder.name.encode("Shift_JIS")}/#{child_file.name.encode("Shift_JIS")}","./public/uploaded/#{child_file.link}#{child_file.filetype}")
                    end
                end
            end
        end
    elsif third_directory(first,second,third)
        folder = VirtualFolder.find(third.to_i)
        files = folder.virtual_files
        Zip::File.open(zipfile,Zip::File::CREATE) do |zip|
            files.each do |file|
                zip.add("#{file.name.encode("Shift_JIS")}","./public/uploaded/#{file.link}#{file.filetype}")
            end
        end
    end
    zipfile_name = folder.name
    send_file(zipfile, :filename => "#{URI.encode(zipfile_name)}.zip")
    redirect "/folders/#{first}/#{second}/#{third}"
end

post /\/folders\/(?:\d*\/)*files\/(\d*)\/download/ do |file_id|
   
   file = VirtualFile.find(file_id.to_i)
   send_file("./public/uploaded/#{file.link}#{file.filetype}", :filename => "#{URI.encode(file.name)}")
   redirect back
end

get "/admin" do
    p session[:master]
    if session[:master]
        erb :admin
    else
        erb :admin_gate
    end
end

post "/admin" do
    if params[:password] == "qwerty"
       session[:master] = true
    else
        session[:master] = false
    end
    redirect back
end

get "/not_found" do
   erb :not_found 
end

get "/clean_up" do
    f = VirtualFolder.where("expire < ?",Date.today)
    f.each do |f|
        f.destroy
    end    
    redirect "/admin"
end

get "/how_to" do
   erb :how_to 
end


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

post /\/folders\/(\d*)\/?(?:\d*\/)*files\/(\d*)\/delete/ do |parent,file_id|
    delete_file = VirtualFile.find(file_id.to_i)
    parent_folder = VirtualFolder.find(parent.to_i)
    
    filepath = "./public/uploaded/#{delete_file.link}#{delete_file.filetype}"
    parent_folder.size -= File.size(filepath)
    parent_folder.save
    File.unlink(filepath)
    delete_file.destroy
    
    redirect back
end

#developing stage
post /\/folders\/(\d*)\/?(?:\d*\/)*files\/(\d*)\/move_file/ do |parent,file_id|
    move_file = VirtualFile.find(file_id)
    move_file.virtual_folder_id = params[:folder].to_i
    move_file.save
end


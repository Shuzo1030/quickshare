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

enable :sessions

@@error = ""

#top page
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

post "/folders/:id/create_folder" do
    folder = VirtualFolder.find(params[:id].to_i)
    
    folder_names = Array.new
    children = folder.children
    children.each_with_index do |child,i|
        folder_names[i] = child.name
    end
    
    if folder_names.include?(params[:name])
        @@error = "folder name already exists"
    else
        VirtualFolder.create(
            name: params[:name],
            password: "child",
            password_confirmation: "child",
            virtual_folder_id: folder.id,
            expire: folder.expire,
            root_id: folder.root_id
        )
    end
    
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
    @dir = @folder.dir
    
    erb :folder
end

#file_upload
post "/folders/:id/upload_file" do
    folder = VirtualFolder.find(params[:id].to_i)
    params[:files].each do |file|
        folder.upload(file)
    end
    redirect back
end

#download
post "/folders/:id/download" do
    folder = VirtualFolder.find(params[:id].to_i)
    temp = SecureRandom.hex(8).to_s
    zipfile = "/tmp/temp_#{temp}.zip"
    Zip::File.open(zipfile,Zip::File::CREATE) do |zip|
        folder.add_zip(zip,"#{folder.name.encode("Shift_JIS")}")
    end
    zipfile_name = folder.name
    send_file(zipfile, :filename => "#{URI.encode(zipfile_name)}.zip")
    
    redirect back
end

post "/folders/:folder_id/files/:file_id/download" do
   file = VirtualFile.find(params[:file_id].to_i)
   send_file("./public/uploaded/#{file.link}#{file.filetype}", :filename => "#{URI.encode(file.name)}")
   redirect back
end

#delete
post "/folders/:id/delete" do
    folder = VirtualFolder.find(params[:id].to_i)
    parent = folder.parent
    root = folder.root?
    folder.delete_folder
    
    if root
        redirect "/"
    else
        redirect "/folders/#{parent.id}"
    end
end

post "/folders/:folder_id/files/:file_id/delete" do
    file = VirtualFile.find(params[:file_id].to_i)
    parent_folder = VirtualFolder.find(VirtualFolder.find(params[:folder_id]).root_id)
    
    filepath = "./public/uploaded/#{file.link}#{file.filetype}"
    parent_folder.size -= File.size(filepath)
    parent_folder.save
    File.unlink(filepath)
    file.destroy
    
    redirect back
end

#developing stage
post "/folders/:folder_id/files/:file_id/move_file" do
    file = VirtualFile.find(params[:file_id].to_i)
    file.virtual_folder_id = params[:folder].to_i
    file.save
    
    redirect "/folders/#{params[:folder].to_i}"
end


#admin
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


get "/clean_up" do
    f = VirtualFolder.where("expire < ?",Date.today)
    f.each do |f|
        f.destroy
    end    
    redirect "/admin"
end

#404
get "/not_found" do
   erb :not_found 
end

#how to
get "/how_to" do
   erb :how_to 
end

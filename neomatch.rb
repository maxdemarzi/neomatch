require 'neography'
require 'sinatra'
require 'oj'

def create_graph
  neo = Neography::Rest.new
   
  names = %w[Emma Olivia Sophia Ava Isabella Mia Ella Emily Chloe Lily Madison Abigail Amelia Charlotte Avery Harper Addison Hannah Grace Sofia Sophie Zoey Zoe Aubrey Natalie Elizabeth Brooklyn Lucy Audrey Claire Evelyn My Anna Layla Lillian Samantha Ellie Maya Stella Leah Liam Ethan Mason Noah Jacob Jack Aiden Jackson Logan Lucas Benjamin William Ryan James Jayden Alexander Michael Owen Elijah Matthew Joshua Luke Dylan Carter Daniel Gabriel Caleb Nathan Henry Oliver Andrew Gavin Evan Landon Max Samuel Eli Connor Tyler Isaac]
  cities = %w[Austin Baltimore Charlotte Chicago Dallas Detroit Miami Oakland Philadelphia Wichita]
  skills = %w[Ruby Java C C++ Python PHP Javascript Neo4j Redis Postgresql MongoDB Rails Node Spring Django UI UX HTML SQL CSS]
  
  commands = []
  names.each { |n| commands <<  [:create_node, {"name" => n}]}
  cities.each { |n| commands <<  [:create_node, {"name" => n}]}
  skills.each { |n| commands <<  [:create_node, {"name" => n}]}
    
  names.each_with_index do |name, x| 
    commands << [:add_node_to_index, "users_index", "name", name, "{#{x}}"]
    commands << [:create_relationship, "lives_in", "{#{x}}", "{#{names.size + rand(cities.size)}}", nil]    
    skills.sample(1 + rand(10)).each do |skill|
      commands << [:create_relationship, "has", "{#{x}}", "{#{names.size + cities.size + skills.index(skill)}}", nil]    
    end
  end

  40.times do |x|
    requirements = skills.sample(3 + rand(2))
    commands << [:create_node, {"name" => requirements.join("-")}]
    offset = commands.size - 1
    commands << [:add_node_to_index, "jobs_index", "name", requirements.join("-"), "{#{offset}}"]
    commands << [:create_relationship, "in_location", "{#{offset}}", "{#{names.size + rand(cities.size)}}", nil]    
    requirements.each do |skill|
      commands << [:create_relationship, "requires", "{#{offset}}", "{#{names.size + cities.size + skills.index(skill)}}", nil]    
    end 
  end

  batch_result = neo.batch *commands
end

class NeoMatch < Sinatra::Application
  set :haml, :format => :html5 
  set :app_file, __FILE__

  get '/' do
    neo = Neography::Rest.new    
    names = %w[Emma Olivia Sophia Ava Isabella Mia Ella Emily Chloe Lily Madison Abigail Amelia Charlotte Avery Harper Addison Hannah Grace Sofia Sophie Zoey Zoe Aubrey Natalie Elizabeth Brooklyn Lucy Audrey Claire Evelyn My Anna Layla Lillian Samantha Ellie Maya Stella Leah Liam Ethan Mason Noah Jacob Jack Aiden Jackson Logan Lucas Benjamin William Ryan James Jayden Alexander Michael Owen Elijah Matthew Joshua Luke Dylan Carter Daniel Gabriel Caleb Nathan Henry Oliver Andrew Gavin Evan Landon Max Samuel Eli Connor Tyler Isaac]
    @user = names.sample
    
    cypher = "START me=node:users_index(name={user})
              MATCH skills<-[:has]-me-[:lives_in]->city<-[:in_location]-job-[:requires]->requirements
              WHERE me-[:has]->()<-[:requires]-job
              WITH DISTINCT city.name as city_name, job.name AS job_name,
              LENGTH(me-[:has]->()<-[:requires]-job) AS matching_skills,
              LENGTH(job-[:requires]->()) AS job_requires,
              COLLECT(DISTINCT requirements.name) AS req_names, COLLECT(DISTINCT skills.name) AS skill_names
              RETURN city_name, job_name, FILTER(name in req_names WHERE NOT name IN skill_names) AS missing
              ORDER BY matching_skills / job_requires DESC, job_requires
              LIMIT 10"

    @jobs = neo.execute_query(cypher, {:user => @user})["data"]   
    haml :index
  end
  
  get'/user/:user/skill/:skill' do
    @user = params[:user]
    @skill = params[:skill]
    haml :skill
  end
  
end
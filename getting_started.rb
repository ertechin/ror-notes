# source https://guides.rubyonrails.org/getting_started.html

# to do: clear and re-write



File/Folder	Purpose
app/	Contains the controllers, models, views, helpers, mailers, channels, jobs, and assets for your application.



To get Rails saying "Hello",
 you need to create at minimum a route,
  a controller with an action, and a view.
   A route maps a request to a controller action.
    A controller action performs the necessary work to handle the request,
     and prepares any data for the view. A view displays data in a desired format.


     When an action does not explicitly render a view (or otherwise trigger an HTTP response), Rails will automatically render a view that matches the name of the controller and action. 


    generate controller view test
     rails generate controller Articles index --skip-routes


     creating routes

     Rails.application.routes.draw do
        root "articles#index"
      
        get "/articles", to: "articles#index"
    end
      
    Application classes and modules are available everywhere,
     you do not need and should not load anything under app with require. This feature is called autoloading, 

        You only need require calls for two use cases:
            To load files under the lib directory.
            To load gem dependencies that have require: false in the Gemfile.

    rails generate model Article title:string body:text
    create a migration file 
    create a model.rb
    create test


    class CreateArticles < ActiveRecord::Migration[7.0]
        def change
          create_table :articles do |t|
            t.string :title
            t.text :body
      
            t.timestamps
          end
        end
      end

      The call to create_table specifies how the articles table should be constructed.
       By default, the create_table method adds an id column as an auto-incrementing primary key.
        So the first record in the table will have an id of 1, the next record will have an id of 2, and so on.

Inside the block for create_table,
 two columns are defined: title and body.
  These were added by the generator because we included them in our generate command (bin/rails generate model Article title:string body:text).

On the last line of the block is a call to t.timestamps. This method defines two additional columns named created_at and updated_at.
 As we will see, Rails will manage these for us, setting the values when we create or update a model object.

 rails db:migrate

 The console is an interactive coding environment just like irb, but it also automatically loads Rails and our application code.
 rails c modeldeki methodlarıda yükler

 article = Article.new(title: "Hello Rails", body: "I am on Rails!")

 article.save

 Article.find(1)

 Article.all

 Controller instance variables can be accessed by the view.

 The <% %> tag means "evaluate the enclosed Ruby code."
  The <%= %> tag means "evaluate the enclosed Ruby code, and output the value it returns."
   Anything you could write in a regular Ruby program can go inside these ERB tags,
    though its usually best to keep the contents of ERB tags short, for readability.

The browser makes a request: GET http://localhost:3000.
Our Rails application receives this request.
The Rails router maps the root route to the index action of ArticlesController.
The index action uses the Article model to fetch all articles in the database.
Rails automatically renders the app/views/articles/index.html.erb view.
The ERB code in the view is evaluated to output HTML.
The server sends a response containing the HTML back to the browser.

get "/articles/:id", to: "articles#show"
@article = Article.find(params[:id])
The returned article is stored in the @article instance variable, so it is accessible by the view. 

resources :articles

Rails provides a routes method named resources that maps all of the conventional routes for a collection of resources, such as articles.

rails routes | grep artic

_url or _path

The link_to helper renders a link with its first argument as the link's text and its second argument as the link's destination.

Typically, in web applications,
 creating a new resource is a multi-step process.
  First, the user requests a form to fill out.
   Then, the user submits the form. If there are no errors, then the resource is created and some kind of confirmation is displayed.
    Else, the form is redisplayed with error messages, and the process is repeated.



    redirect_to will cause the browser to make a new request, whereas render renders the specified view for the current request.
     It is important to use redirect_to after mutating the database or application state.
      Otherwise, if the user refreshes the page, the browser will make the same request, and the mutation will be repeated.



      Submitted form data is put into the params Hash, alongside captured route parameters.
       Thus, the create action can access the submitted title via params[:article][:title] and the submitted body via params[:article][:body].
        We could pass these values individually to Article.new, but that would be verbose and possibly error-prone.
         And it would become worse as we add more fields.
         Otherwise, a malicious user could potentially submit extra form fields and overwrite private data.
          In fact, if we pass the unfiltered params[:article] Hash directly to Article.new, Rails will raise a ForbiddenAttributesError to alert us about the problem.

          private
          def article_params
            params.require(:article).permit(:title, :body)
          end

          Rails provides a feature called validations to help us deal with invalid user input.
          Validations are rules that are checked before a model object is saved. 
          If any of the checks fail, the save will be aborted,
           and appropriate error messages will be added to the errors attribute of the model object.

           You may be wondering where the title and body attributes are defined.
            Active Record automatically defines model attributes for every table column,
             so you don't have to declare those attributes in your model file.'


            <% @article.errors.full_messages_for(:body).each do |message| %>
            <div><%= message %></div>
            <% end '%>'
        
            The full_messages_for method returns an array of user-friendly error messages for a specified attribute.
             If there are no errors for that attribute, the array will be empty.

             When we submit the form, the POST /articles request is mapped to the create action.
              The create action does attempt to save @article.
               Therefore, validations are checked.
                If any validation fails, @article will not be saved, and app/views/articles/new.html.erb will be rendered with error messages.

                The edit action fetches the article from the database, and stores it in @article so that it can be used when building the form.
                 By default, the edit action will render app/views/articles/edit.html.erb.

 The update action (re-)fetches the article from the database,
 and attempts to update it with the submitted form data filtered by article_params.
   If no validations fail and the update is successful, the action redirects the browser to the article's page.
   Else, the action redisplays the form — with error messages — by rendering app/views/articles/edit.html.erb.'

   Our edit form will look the same as our new form.
    Even the code will be the same, thanks to the Rails form builder and resourceful routing.
     The form builder automatically configures the form to make the appropriate kind of request,
      based on whether the model object has been previously saved.
          
      A partial's filename must be prefixed with an underscore, e.g. _form.html.erb.
       But when rendering, it is referenced without the underscore, e.g. render "form".'


      <h1><%= @article.title %></h1>

      <p><%= @article.body %></p>
      
      <ul>
        <li><%= link_to "Edit", edit_article_path(@article) %></li>
        <li><%= link_to "Destroy", article_path(@article), data: {
                          turbo_method: :delete,
                          turbo_confirm: "Are you sure?"
                        } %>'</li>
      </ul>

      In the above code, we use the data option to set the data-turbo-method and data-turbo-confirm HTML attributes of the "Destroy" link.
       Both of these attributes hook into Turbo, which is included by default in fresh Rails applications
       . data-turbo-method="delete" will cause the link to make a DELETE request instead of a GET request.
        data-turbo-confirm="Are you sure?" will cause a confirmation dialog to appear when the link is clicked. If the user cancels the dialog, the request will be aborted.


      rails generate model Comment commenter:string body:text article:references
      The (:references) keyword used in the shell command is a special data type for models.
       It creates a new column on your database table with the provided model name appended with an _id that can hold integer values. 

       class Comment < ApplicationRecord
        belongs_to :article
      end

      class Article < ApplicationRecord
        has_many :comments
      
        validates :title, presence: true
        validates :body, presence: true, length: { minimum: 10 }
      end
      
      Each comment belongs to one article.
      One article can have many comments.

      These two declarations enable a good bit of automatic behavior.
       For example, if you have an instance variable @article containing an article,
        you can retrieve all the comments belonging to that article as an array using @article.comments.

        resources :articles do
          resources :comments
        end

  This creates comments as a nested resource within articles.
    This is another part of capturing the hierarchical relationship that exists between articles and comments.


    Concerns are a way to make large controllers or models easier to understand and manage.
     This also has the advantage of reusability when multiple models (or controllers) share the same concerns.
      Concerns are implemented using modules that contain methods representing a well-defined slice of the functionality that a model or controller is responsible for.
       In other languages, modules are often known as mixins.

       If you delete an article, its associated comments will also need to be deleted,
        otherwise they would simply occupy space in the database. dependent: :destroy
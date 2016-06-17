#Haskell-Project

##1. Components:
###1.1. Web-Interface: 
####1.1.1. Technologies:
On the server side, I’m using the snap Framework as it offers a stable and efficient web development framework. http://snapframework.com/
I wanted to try some auto-webpage-generation technologies but I found that this will be a very time-costly operation so I left it to the end to see if I would have time for it. For more information about webpages auto-generation: http://blog.dandyer.co.uk/2008/12/03/generating-html-with-haskell/
####1.1.2. Process:
The Snap-Framework offers easy ways to handle GET requests, but I had a lot of troubles handling the POST requests, because the received parameters are always of the type ByteString, which I couldn’t handle properly. I had another Problem with the POST-requests, that whenever I ran a query to the database, the return type had always the constructor IO. The snap Framework didn’t expect such a constructor as a value, so I had to use the unsafe function unsafePerformIO to get rid of the constructor.
To send my data to the client, I made instances of ToJSON to send the data in a proper way. I read later that one could derive the class Generic to replace this process but when I tried it it didn’t work and as I had a done solution for my project I haven’t searched for the reason.

###1.2. Database: 
####1.2.1. Technologies:
I’m using PostgreSQL as a database to persist my data. While trying to connect the database to my haskell program I tried the two available Libraries: Database.HDBC.PostgreSQL and Database.PostgreSQL.Simple. Both Libraries worked perfectly but I choose to use the PostgreSQL.Simple for this project to keep the work simple and compact.
A very helpful tutorial to connect haskell to databases can be found here: http://book.realworldhaskell.org/read/using-databases.html
####1.2.2. Process:
At the start I had problems reading the results of the queries I executed to the database. I tried to parse the results manually and this was a lot of work. After a bit of research I tried creating instances of FromRow and this automated the parsing process of the resulted rows. Elsewise was the process with databases the most fluid part of my project.

####1.2.3. EER Diagram:
![alt tag](http://s33.postimg.org/gyi1t93ov/La_Liga_1.png)
###1.3. Client side:
####1.3.1. Technologies:
On the client side, the webpages are created with HTML and CSS and controlled with AngularJS, which sends requests to the server and handles the responses and generates parts of the pages. Helpful project: https://github.com/nurpax/snap-examples/blob/master/angularjs-todo/static/index.html
####1.3.2. Process:
As a starter with AngularJS, I had to learn a bit about it before being able to send GET and POST requests and read the received data from the responses and put it in the right place in the page. Here I will not describe the process in details because the concentration is about haskell.

##2. Running the Project:
###2.1. Installing:
In the project folder run 
`cabal install`
to install and compile the project.
###2.2. Preparing the Database:
PostgreSQL must be installed on the server. Run the following command to create the database: 
`createdb -h localhost -p 5432 -U postgres -W testDB`
Then simply run this command to initialise the database: 
`psql -U postgres -d testDB --file=DB/query.sql`
###2.3. Starting the Webserver:
In the project folder run the command: `haskell-projekt -p PORT`. This launches the server on the given port. On a web browser you can now access the page on `http://localhost:PORT`


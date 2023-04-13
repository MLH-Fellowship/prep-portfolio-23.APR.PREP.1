---
layout: post
author: Chukwuka Ikeh
title: Building a CRUD Microservice using gRPC in Go
headline: Optional headline goes here
---

<p align="center">
  <img src="../assets/img/posts/IMG_6689.jpeg" alt="Building a CRUD Microservice using gRPC in Go" width="700"/>
</p>

gRPC is a powerful tool for building distributed systems and microservices and is a great choice for developers who need a high-performance, reliable communication mechanism between their applications.

In this article, we'll walk you through the process of building a Microservice using gRPC in Go, starting with setting up your development environment and defining the service's API using Protocol Buffers. You'll learn how to implement the service's business logic, as well as the gRPC server and client. By the end of this article, you'll have a good understanding of how to design and build a Microservice using gRPC in Go.

## Introduction to Microservices and gRPC
Microservices is an architectural style that structures an application as a collection of small, independent services, each running its own process and communicating with lightweight mechanisms, often an HTTP API. The goal of microservices is to enable fast delivery of large and complex applications, increase efficiency and scalability, and allow for a more agile development process.

The main advantage of microservices is the ability to develop, deploy, and scale services independently, leading to faster release cycles, increased deployment efficiency, and reduced downtime. Additionally, small, cross-functional teams can develop and maintain microservices, leading to faster innovation and reduced time-to-market.

However, there are also some disadvantages of microservices to consider. The complexity of communication between services can increase, leading to the need for additional management and orchestration tools. Additionally, there may be increased operational overhead and increased latency due to the need for inter-service communication.

gRPC is a high-performance, open-source framework for building scalable, modern, and fast APIs. It uses the Protocol Buffers data format and supports various programming languages. gRPC is based on the concept of remote procedure calls (RPCs), where a client can make a request to a server and receive a response as if it were calling a local function.

gRPC uses HTTP/2 for transport, allowing for bi-directional streaming and flow control, which enables faster and more efficient communication between services. The use of Protocol Buffers provides a compact and efficient way to serialize data, leading to faster and more reliable communication.

One of the main advantages of using gRPC is its high performance and low latency. Additionally, its use of Protocol Buffers can lead to smaller payload sizes, resulting in faster transmission times and reduced network bandwidth usage. Another advantage is the ability to easily generate client and server code in various programming languages, which can reduce the time and effort required to implement new services.

However, there are also some disadvantages to using gRPC. One is the limited browser support, as gRPC currently relies on HTTP/2, which is not widely supported in browsers. Additionally, gRPC may have a steeper learning curve for developers unfamiliar with Protocol Buffers or remote procedure calls. Another consideration is that gRPC requires more upfront design and planning than REST-based APIs. This can lead to a longer development cycle and require a deeper understanding of gRPC and Protocol Buffers.

Finally, it's important to note that gRPC may not be the best fit for all use cases. In situations where REST-based APIs are sufficient, it may be an over-engineering solution. Additionally, gRPC may not be well-suited for applications that require real-time updates or notifications, as the request/response nature of gRPC may not provide the necessary real-time updates.

## Setting up the development environment
Setting up the development environment for a gRPC project in Go is crucial in getting started with the project. The following steps outline the process for installing the required components and setting up the development environment:

Setup a module environment for the gRPC project by running the following `go mod` command in the project directory (for example, pieces-grpc):

```sh
go mod init github.com/IkehAkinyemi/grpc-service
```

Note to replace `IkehAkinyemi` with your GitHub username if it’s your preferred repository, and if not, do well to choose the preferred repository link.

Next in the setup is installing the Protocol Buffers compiler and gRPC plugins for Go. The first step in setting up the development environment is to install the Protocol Buffers compiler (protoc) using the macOS package manager:

```sh
brew install protobuf
```
Check here if you’re using a different OS environment to follow along with the tutorial. Then check if the installation was successfully executed by running the below command:

```sh
protoc --version  #libprotoc 3.21.12
```
Next, let’s complete the setup by installing some Go plugins for the project. The easiest way to do this is to use the Go package manager, `go get`, to install the required components. The following command can be run in a terminal to install the necessary components:

```sh
go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
go install google.golang.org/grpc/cmd/protoc-gen-go-grpc
```
After downloading the plugins, let’s define a simple CRUD service. The first step is to define the service API using the Protocol Buffers language. This is done by creating a .proto file, which defines the service and its methods. The following example shows how to define a CRUD (Create, Read, Update, Delete) service API:

```proto
//File: pieces-grpce/api/user.proto
syntax = "proto3";

option go_package = "/gen";

service UserService {
    rpc CreateUser(CreateUserRequest) returns (CreateUserResponse) {}
    rpc ReadUser(ReadUserRequest) returns (ReadUserResponse) {}
    rpc UpdateUser(UpdateUserRequest) returns (UpdateUserResponse) {}
    rpc DeleteUser(DeleteUserRequest) returns (DeleteUserResponse) {}
}
message CreateUserRequest {
    string name = 1;
    int32 age = 2;
}
message CreateUserResponse {
    string id = 1;
}
message ReadUserRequest {
    string id = 1;
}
message ReadUserResponse {
    string name = 1;
    int32 age = 2;
}
message UpdateUserRequest {
    string id = 1;
    string name = 2;
    int32 age = 3;
}
message UpdateUserResponse {
}
message DeleteUserRequest {
    string id = 1;
}
message DeleteUserResponse {
}
```
This Protocol Buffer message definition defines a gRPC service named `UserService` with 4 remote procedure calls (RPC): `CreateUser`, `ReadUser`, `UpdateUser`, and `DeleteUser`. Each RPC maps a request message to a response message. Each RPC's request and response messages are defined as separate message types, such as `CreateUserRequest` and `CreateUserResponse`. The messages contain fields, such as `name` and `age`, in the `CreateUserRequest`, each with a unique field number tag. The syntax specified at the beginning of the file is protobuf version 3. To learn more about the Protocol Buffer message definition, check [here](https://developers.google.com/protocol-buffers/docs/proto3).

```sh
protoc --proto_path=. --go_out=. \
  --go-grpc_out=. \
  ./api/*.proto
```
Use protoc with the following options: `--proto_path=., --go_out=.`, `--go-grpc_out=.`, to compile the `.proto` files in the `api` directory and generate `.pb.go` files in the same directory as the package name specified using `option go_package` in the input files, preserving their sub-directory structure if any, but not creating the output directory. Check the `./gen` folder to see the generated Go code. To learn more about the generated code, check [here](https://developers.google.com/protocol-buffers/docs/reference/go-generated#package).

With the development environment set up and the `.proto` file defining the service API, the next step is implementing the gRPC service and client in Go. The following outlines the process for implementing the service and client, using a simple business logic that operates CRUD on an in-memory map object type in Go.

Let’s start with the implementation of the server by defining the struct that would serve as both the controller and in-memory repository:

```go
// File: pieces-grpc/internal/handler/grpc.go
package handler

import (
  "github.com/IkehAkinyemi/grpc-service/gen"
) 

type Handler struct {
  gen.UnimplementedUserServiceServer
  users map[string]user
}

type user struct {
  Name string
  Age  int32
}

func New() *Handler {
  return &Handler{users: make(map[string]user)}
}
```

The code defines a `handler` package in Go. This package contains a `Handler` struct that implements the generated `gen.UnimplementedUserServiceServer` interface. The `Handler` struct also has a `users` field of type `map[string]user`.

The `user` struct represents a user with fields `Name` and `Age`. The `New` function returns a pointer to a new instance of the `Handler` struct, which is an implementation of the `gen.UnimplementedUserServiceServer` interface.

The `users` field is a map from strings (representing the user's unique identifier) to instances of the user struct. The `gen.UnimplementedUserServiceServer` interface represents the generated code for a gRPC service, and the `Handler` struct implements the methods in this interface. The business logic for the gRPC service will be added to the methods in this implementation.

Let’s complete the business logic by implementing the methods defined by `gen.UnimplementedUserServiceServer` for the `Handler` struct, thereby overriding the `gen.UnimplementedUserServiceServer`'s inherited methods.

```go
// File: pieces-grpc/internal/handler/grpc.go
package handler

import (
  "context"
  "github.com/IkehAkinyemi/grpc-service/gen"
  "github.com/google/uuid"
  "google.golang.org/grpc/codes"
  "google.golang.org/grpc/status"
)

// --snip--

func (h *Handler) CreateUser(ctx context.Context, req *gen.CreateUserRequest) (*gen.CreateUserResponse, error) {
  id := uuid.New().String()
  h.users[id] = user{
      Name: req.Name,
      Age:  req.Age,
  }
  return &gen.CreateUserResponse{Id: id}, nil
}

func (h *Handler) ReadUser(ctx context.Context, req *gen.ReadUserRequest) (*gen.ReadUserResponse, error) {
  u, ok := h.users[req.Id]
  if !ok {
      return nil, status.Errorf(codes.NotFound, "user not found")
  }
  return &gen.ReadUserResponse{
      Name: u.Name,
      Age:  u.Age,
  }, nil
}

func (h *Handler) UpdateUser(ctx context.Context, req *gen.UpdateUserRequest) (*gen.UpdateUserResponse, error) {
  u, ok := h.users[req.Id]
  if !ok {
      return nil, status.Errorf(codes.NotFound, "user not found")
  }
  u.Name = req.Name
  u.Age = req.Age
  h.users[req.Id] = u
  return &gen.UpdateUserResponse{}, nil
}

func (h *Handler) DeleteUser(ctx context.Context, req *gen.DeleteUserRequest) (*gen.DeleteUserResponse, error) {
  delete(h.users, req.Id)
  return &gen.DeleteUserResponse{}, nil
}
```

The code defines four methods for the `Handler` struct, each of which implements a different gRPC API endpoint for performing CRUD (Create, Read, Update, Delete) operations on users.

`CreateUser` generates a new user ID using the `uuid` package, adds a new user to the `users` map using this ID as the key, and returns a `CreateUserResponse` containing the new user ID.

`ReadUser` retrieves the user with the given ID from the `users` map, and returns a `ReadUserResponse` containing the user's name and age. If the user is not found, the method returns an error with a `NotFound` status.

`UpdateUser` retrieves the user with the given ID from the users map, updates the user's name and age, and adds the updated user back to the map. If the user is not found, the method returns an error with a `NotFound` status.

`DeleteUser` deletes the user with the given ID from the users map.

These methods represent the business logic for the gRPC service and handle the various requests from clients to perform CRUD operations on the in-memory user data.

Next. let’s implement the server logic, connecting it to the business logic.

```go
// File: pieces-grpc/cmd/server/main.go
package main
import (
  "fmt"
  "log"
  "net"
  "github.com/IkehAkinyemi/grpc-service/gen"
  "github.com/IkehAkinyemi/grpc-service/internal/handler"
  "google.golang.org/grpc"
  "google.golang.org/grpc/reflection"
)

func main() {
  log.Println("Starting the sever")
  port := 50051
  listener, err := net.Listen("tcp", fmt.Sprintf("localhost:%d", port))
  if err != nil {
    log.Fatalf("failed to listen: %v", err)
  }
  h := handler.New()
  srv := grpc.NewServer()
  reflection.Register(srv)
  gen.RegisterUserServiceServer(srv, h)
  if err := srv.Serve(listener); err != nil {
    panic(err)
  }
}
```

The above snippet is the main function that starts a gRPC server on port `8080`. It creates a new handler object and uses it to register the `UserService` with the gRPC server. The server then listens on the specified port, and if there is an error, it will log the error and stop.

Next, let’s setup a client CLI program to communicate with the gRPC server like below:

```go
// File: pieces-grpc/cmd/client/main.go
package main

import (
  "log"
  "github.com/IkehAkinyemi/grpc-service/gen"
  "google.golang.org/grpc"
  "google.golang.org/grpc/credentials/insecure"
)
func main() {
  conn, err := grpc.Dial("localhost:50051", grpc.WithTransportCredentials(insecure.NewCredentials()))
  if err != nil {
    log.Fatalf("did not connect: %v", err)
  }
  defer conn.Close()
  client := gen.NewUserServiceClient(conn)
}
```
This is the main Go code for the gRPC client. The code creates a client connection to a gRPC server running on `localhost:50051` using an insecure transport channel. If the connection is successful, the conn variable holds the connection to the server. The code creates a client to the gRPC server's UserService by calling the `gen.NewUserServiceClient` function and passing it the conn variable. The client is then ready to send requests to the UserService. If there's an error while creating the connection, the code logs the error message and terminates the client. The `defer` statement closes the connection to the server when the client is done.

Next, let’s setup utility functions to send requests to the server using the client to create, read, update or delete a user:

```go
// File: pieces-grpc/cmd/client/user_utils.go

// createUser inserts a random user into the in-memory repository.
func createUser(ctx context.Context, client gen.UserServiceClient) string {
  user := generateUser()
  resp, err := client.CreateUser(ctx, &gen.CreateUserRequest{
    Name: user.Name,
    Age:  int32(user.Age),
  })
  if err != nil {
    log.Fatalf("could not create user: %v", err)
  }
  return resp.Id
}

// readUser returns a user with the id parameter.
func readUser(ctx context.Context, client gen.UserServiceClient, id string) user {
  readResp, err := client.ReadUser(ctx, &gen.ReadUserRequest{Id: id})
  if err != nil {
    log.Fatalf("could not read user: %v", err)
  }
  return user{
    Name: readResp.Name,
    Age:  readResp.Age,
  }
}

// updateUser return an updated user info.
func updateUser(ctx context.Context, client gen.UserServiceClient, id string) user {
  _, err := client.UpdateUser(ctx, &gen.UpdateUserRequest{
    Id:  id,
    Age: randomInt(1, 100),
  })
  if err != nil {
    log.Fatalf("could not update user: %v", err)
  }
  return readUser(ctx, client, id)
}

// deleteUser deletes a user with the id parameter.
func deleteUser(ctx context.Context, client gen.UserServiceClient, id string) {
  _, err := client.DeleteUser(ctx, &gen.DeleteUserRequest{Id: id})
  if err != nil {
    log.Fatalf("could not delete user: %v", err)
  }
  log.Printf("Deleted User with ID: %s", id)
}
```
These are 4 functions that perform CRUD operations on a user in a gRPC service.

- The `createUser` function takes a context and client as parameters, generates a random user, and creates it by sending a CreateUserRequest to the server. If successful, it returns the id of the created user. If not, it logs a fatal error message.

- The `readUser` function takes a context, client, and id as parameters and retrieves a user from the server by sending a ReadUserRequest with the given id. If successful, it returns the retrieved user. If not, it logs a fatal error message.

- The `updateUser` function takes a context, client, and id as parameters and updates a user on the server by sending a UpdateUserRequest with the given id and a randomly generated age. If successful, it returns the updated user. If not, it logs a fatal error message.

- The `deleteUser` function takes a context, client, and id as parameters and deletes a user from the server by sending a DeleteUserRequest with the given id. If successful, it logs a message indicating the user was deleted. If not, it logs a fatal error message.

With these functions defined, let’s update the `main` function to perform either create, read, update, or delete based on the flag argument:

```go
// File: pieces-grpc/cmd/client/main.go
--snip--
func main() {
  var create bool
  var read bool
  var update bool
  var delete bool
  flag.BoolVar(&create, "c", false, "Create a user request")
  flag.BoolVar(&read, "r", false, "Retrieve a user request")
  flag.BoolVar(&update, "u", false, "Update a user request")
  flag.BoolVar(&delete, "d", false, "Delete a user request")
  flag.Parse()

  --snip--

  userID := string(flag.Arg(0))
  if create {
    userID := createUser(ctx, client) // Create User
    log.Printf("Created User with ID: %s", userID)
  } else if read {
    newUser := readUser(ctx, client, userID) // Read User
    log.Printf("Read User: %+v", newUser)
  } else if update {
    updatedUser := updateUser(ctx, client, userID) // Update User
    log.Printf("Updated User %+v with ID: %s", updatedUser, userID)
  } else if delete {
    deleteUser(ctx, client, userID) // Delete User
  }
}
```
Now we have the client ready, use the following commands to spin the gRPC server, and make requests to it using the client like below:

```sh
go run ./cmd/server/*

# open a new terminal, run the following
go run ./cmd/client/* -c # create user

go run ./cmd/client/* -r <user_id> # retrieve a user using returned id

go run ./cmd/client/* -u <user_id> # update user

go run ./cmd/client/* -d <user_id> # delete a user
```

## Conclusion
In conclusion, this article has discussed the implementation of a gRPC service for user management. The server is implemented in Go and uses gRPC to handle client requests and the underlying communication between the client and server. The service is defined in a .proto file, and the generated code is used to implement the server and client. The implementation of the service provides basic CRUD operations for user management, such as creating, reading, updating, and deleting users. The gRPC client establishes a connection to the server and uses the generated client code to interact with the service. For the entire codebase, please check [here](https://github.com/IkehAkinyemi/grpc-service).


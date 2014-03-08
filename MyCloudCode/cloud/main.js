  // Use Parse.Cloud.define to define as many cloud functions as you want.
  // For example:
  Parse.Cloud.define("hello", function(request, response) {
    response.success("Hello world!");
  });

  // Make sure all installations point to the current user.
  Parse.Cloud.beforeSave(Parse.Installation, function(request, response) {
    Parse.Cloud.useMasterKey();
    if (request.user) {
      request.object.set('user', request.user);
    } else {
      request.object.unset('user');
    }
    response.success();
  });

  Parse.Cloud.afterSave('Chat', function(request) {
    request.object.fetch({
        success: function(chat){
            alert("request object id" + chat.id);
            alert("sender id " + chat.get('sender').id);

            chat.get('sender').fetch({
                success: function(Sender){

                    var query = new Parse.Query(Parse.Installation);
                    query.containedIn('user', chat.get("participants")); // request.object.get is [] so sends to all push registered users
                    query.notEqualTo('user', chat.get('sender'));
                    Parse.Push.send({
                    where: query, // sets our installation query
                    data : {
                        alert: 'Message from ' + chat.get("sender").get('profileName'),
                        badge: "Increment",
                        p: "m",
                        fu: chat.get("sender").get('profileName'),//Chat.object.get("sender").profileName, // Sender id // TODO: send user name insted
                        },                          
                    });


                    // alert("sender name " + JSON.stringify(chat.get('sender'), null));
                    // alert("participants are " + chat.get('participants'));
                    // alert("sender looks like " + JSON.stringify(chat, null));
                }
            });
        }
    });
  });
    // var query = new Parse.Query(Parse.Installation);
    // query.equalTo('user', request.object.get("toUser"));

    // Parse.Push.send({
    //   where: query, // set our installation query.
    //   data: {
    //     alert: request.object.get("message"),
    //     badge: "Increment",
    //     p: "m", // PayLoad Type is Message
    //     fu: request.object.get('fromUser').id, //From User ID
    //    },
    //  });

    // // update other table in database to reflect new message sent
    // var query = new Parse.Query("MessageCount");

    // // try to retrieve object and update count
    // // if failed try to save new object with count
    // query.equalTo("toUser", request.object.get("toUser"));
    // alert("object id is " + request.object.get("toUser").id)
    // query.find({
    //   success: function(results) {
    //     alert("successfully found an item with id ");
    //             alert("didn't find object so creating a new one");
    //     if (results) {
    //         results[0].set("fromUser", request.object.get("fromUser"));
    //         results[0].set("toUser", request.object.get("toUser"));
    //         results[0].set("unreadMessageCount", 1);
    //         results[0].save(null, {
    //         success: function(query) {
    //           alert("created a new object after not finding original")
    //         },
    //         error: function(query, error) {
    //           alert("Couldn't create a new object");
    //         }
    //       }); 
    //     }
    //   },
    //   error: function(results, error) {

    //   }
    // });

    // var MessageCount = Parse.Object.extend("MessageCount");
    // var messageCount = new MessageCount();
    
    // messageCount.set("fromUser", request.object.get("fromUser"));
    // messageCount.set("toUser", request.object.get("toUser"));
    // messageCount.set("unreadMessageCount", 1);
    // messageCount.save(null, {});




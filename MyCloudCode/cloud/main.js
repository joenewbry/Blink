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

  Parse.Cloud.afterSave('Message', function(request) {
    var query = new Parse.Query(Parse.Installation);
    query.equalTo('user', request.object.get("toUser"));

    Parse.Push.send({
      where: query, // set our installation query.
      data: {
        alert: request.object.get("message"),
        badge: "Increment",
        p: "m", // PayLoad Type is Message
        fu: request.object.get('fromUser').id, //From User ID
       },
     });

    // update other table in database to reflect new message sent
    var query = new Parse.Query("MessageCount");

    // try to retrieve object and update count
    // if failed try to save new object with count
    query.equalTo("toUser", request.object.get("toUser"));
    alert("object id is " + request.object.get("toUser").id)
    query.find({
      success: function(results) {
        alert("successfully found an item with id ");
                alert("didn't find object so creating a new one");
        if (results) {
            results[0].set("fromUser", request.object.get("fromUser"));
            results[0].set("toUser", request.object.get("toUser"));
            results[0].set("unreadMessageCount", 1);
            results[0].save(null, {
            success: function(query) {
              alert("created a new object after not finding original")
            },
            error: function(query, error) {
              alert("Couldn't create a new object");
            }
          }); 
        }
      },
      error: function(results, error) {

      }
    });

    var MessageCount = Parse.Object.extend("MessageCount");
    var messageCount = new MessageCount();
    
    messageCount.set("fromUser", request.object.get("fromUser"));
    messageCount.set("toUser", request.object.get("toUser"));
    messageCount.set("unreadMessageCount", 1);
    messageCount.save(null, {});

  }); 





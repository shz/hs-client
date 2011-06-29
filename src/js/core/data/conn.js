
dep.require('util');
dep.require('hs.loading');

dep.provide('hs.con');

window.i = 1;

hs.con = {
  log: false,

  connect: function(){
    var ioReady = _.bind(function(){
      this.socket = new io.Socket(conf.server.host, {
        port: conf.server.port
      });
      this.socket.on('connect', this._connected);
      this.socket.on('message', this._recieved);
      this.socket.on('disconnect', this._disconnected);
      this.socket.connect();
    }, this);

    if (typeof io == 'undefined'){
      hs.loadScript(conf.server.protocol+'://'
          +conf.server.host+':'+conf.server.port
          +'/socket.io/socket.io.js');
      (function ioCheck(){
        if (typeof io == 'undefined')
          setTimeout(ioCheck, 10);
        else
          ioReady();
      })();
    }else{
      ioReady();
    }
  },

  _isConnected: false,
  isConnected: function(clbk, context){
    if (!clbk) return this._isConnected;

    if (this._isConnected)
      clbk.call(context);
    else
      this.once('connected', clbk, context);
  },

  disconnect: function(clbk, context){
    if (clbk) this.once('disconnected', clbk, context);
    this.socket.disconnect();
  },

  reconnect: function(clbk, context){
    if (clbk) this.once('connected', clbk, context);
    this.disconnect(this.connect, this);
  },

  msgId: 1,
  send: function(key, data, clbk, context){
    var msgId = this.msgId++;
    this.isConnected(_.bind(function(){
      this.trigger('sending', key, data);
      this.trigger('sending:'+key, data);
      if (typeof data == 'undefined') data = {};
      data.id = msgId;
      var msg = key+':'+JSON.stringify(data);

      hs.loading();
      this.once('recieved:'+msgId, function(key, data){
        hs.loaded();
        if (clbk) clbk(data.value, data.error);
      });

      this.socket.send(msg);
      if (this.log) hs.log('sent:', msg);
    }, this));
    return msgId;
  },

  _connected: function(){
    hs.log('connected to server');
    this._isConnected = true;
    this.trigger('connected');

    //bootstrap the prsence process
    $(document.body).bind('mousemove', hs.con.moveOnline);
  },

  _recieved: function(msg){
    if (this.log) hs.log('recd:', msg);

    var parsed = msg.split(':'),
        key = parsed.shift(),
        data = JSON.parse(parsed.join(':'));
    this.trigger('recieved', key, data);
    this.trigger('recieved:'+data.id, key, data);
    this.trigger(key, data);
  },

  _disconnected: function(){
    hs.log('disconnected from server');
    hs.resetLoading();
    this._isConnected = false;
    this.trigger('disconnected');

    $(document.body).unbind('mousemove', hs.con.moveOnline);
    $(document.body).unbind('mousemove', hs.con.moveOffline);
    $(document.body).one('mousemove', hs.con.moveOffline);
  },

  //keeps track of whether the mouse moved in the last check interval
  moved: true,
  //the disconnect timeout
  dcTo: null,

  //handles moved events when the user is online
  moveOnline: function() { hs.con.moved = true; },

  //handles moved events when the user is offline
  moveOffline: function() {
    //reconnect
    hs.log('user is no longer away');
    hs.con.connect();
  },

  //this interval runs every second and handles the real movement
  //logic.  we do this in the relatively long (1s) timeout rather
  //than the mousemove handler to avoid destroying performance
  mouseTo: setInterval(function() {

    //if there was movement, do stuff
    if (hs.con.moved) {
      //cancel the existing disconnect timeout if there is one
      if (hs.con.dcTo) clearTimeout(hs.con.dcTo);

      //set the dc timeout to handle the disconnect logic
      hs.con.dcTo = setTimeout(function() {

        hs.log('user is away');
        hs.con.disconnect();

        //ensure that mouseTo won't trigger while the user is offline
        hs.con.moved = false;

      // CHANGE AWAY TIMING HERE
      }, 30 * 1000); //30 seconds

      //clear the moved state
      hs.con.moved = false;
    }

    //if there wasn't movement, we have absolutely nothing to do
  }, 1000)

}
_.bindAll(hs.con);
_.extend(hs.con, Backbone.Events);

hs.con.connect();

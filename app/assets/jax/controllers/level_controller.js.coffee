Jax.Controller.create "Level", ApplicationController,
  index: ->
    # initialize keyboard movements
    @movement = { up: 0, down: 0, left: 0, right: 0 }
    
    # unload old level if exists
    @unload_level(@level)
    
    # load selected level and add it to the world
    @level = Level.find "actual"
    @world.addObject @level
    
    # Initalize path
    @path = Path.find "actual"
        
    # load the components of the level and add them on the world
    for i in [0..@level.cols_number*@level.rows_number-1]
      if @level.objects[i]
        @world.addObject @level.objects[i]
      
  update: (timechange) ->    
    ;
    
  key_pressed: (event) ->
    has_moved = 0
    has_deleted = 0
    
    move_letter = ' '
    switch event.keyCode
      when KeyEvent.DOM_VK_UP    then move_letter = 'u'
      when KeyEvent.DOM_VK_DOWN  then move_letter = 'd'
      when KeyEvent.DOM_VK_LEFT  then move_letter = 'l'
      when KeyEvent.DOM_VK_RIGHT then move_letter = 'r'
      when KeyEvent.DOM_VK_D     then has_deleted = @level.delete_last_move(@path)
      
    has_moved = @level.move(move_letter)

    # if moved, refresh concerned level positions objects
    if has_moved != 0
      # save move
      @path.add_move(move_letter) if has_moved == 1
      @path.add_push(move_letter) if has_moved == 2

    if has_moved != 0 or has_deleted != 0
      @refresh_level(@level, has_deleted)
  
  # FIXME optimize squares to refresh (REVERSE !)
  refresh_level: (level, has_deleted = 0) ->
      # take the new pusher position and its 4 direct neighbours
      pusher_m = level.pusher_pos_m
      pusher_n = level.pusher_pos_n
      positions =
        [
          [pusher_m,   pusher_n]
          [pusher_m+1, pusher_n]
          [pusher_m-1, pusher_n]
          [pusher_m,   pusher_n+1]
          [pusher_m,   pusher_n-1]
        ]
      
      # if deleted move, refresh its 8 neighbours
      if has_deleted
        position.push( [pusher_m+2, pusher_n] )
        position.push( [pusher_m-2, pusher_n] )
        position.push( [pusher_m,   pusher_n+2] )
        position.push( [pusher_m,   pusher_n-2] )
   
      # visually refresh these 9 positions
      for position in positions
        index = level.cols_number*position[0] + position[1]
        if level.read_pos(position[0], position[1]) != 'E'
          level.display_position(position[0], position[1])
          
  unload_level: (level) ->
    if level
      for i in [0..level.cols_number*level.rows_number-1]
        if level.objects[i]
          @world.removeObject level.objects[i].__unique_id
          level.objects[i].dispose()
          delete level.objects[i]
      @world.removeObject level.__unique_id
      delete level.objects
      delete level.grid

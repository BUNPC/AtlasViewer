function layer = initLayer()


layer.filename = '';
layer.isvolume = true;
layer.volume = MRIinit();

layer.mesh = initMesh();
layer.surf2vol = eye(4);
layer.vol2surf = eye(4);
layer.tiss_type = {};
layer.orientation = '';
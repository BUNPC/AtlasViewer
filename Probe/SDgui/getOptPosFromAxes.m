function optpos=getOptPosFromAxes(h_nodes)

    optpos=[];
    for i=1:length(h_nodes)
        optpos(i,:) = get(h_nodes(i),'position');
    end


function configureGraph(title, graphId, graphData, chartKey, chartLabels, ymax) {
    var dailyLine = new RGraph.Line( graphId, graphData );

    dailyLine.Set('chart.title', title);
    dailyLine.Set('chart.background.barcolor1', 'white');
    dailyLine.Set('chart.background.barcolor2', 'white');
    dailyLine.Set('chart.background.grid', true);
    dailyLine.Set('chart.linewidth', 2);
    dailyLine.Set('chart.gutter', 30);
    dailyLine.Set('chart.hmargin', 5);
    dailyLine.Set('chart.shadow', false);
    dailyLine.Set('chart.tickmarks', null);
    dailyLine.Set('chart.units.post', 's');
    dailyLine.Set('chart.xticks', 8);
    dailyLine.Set('chart.background.grid.autofit', true);
    dailyLine.Set('chart.background.grid.autofit.numhlines', 20);
        
    dailyLine.Set('chart.scale.round', false);
    dailyLine.Set('chart.ymax', ymax);
    dailyLine.Set('chart.outofbounds', true);
    dailyLine.Set('chart.text.angle', 0);
    dailyLine.Set('chart.colors', ['#f00', '#0f0', '#00f', '#f0f', '#ff0', '#0ff', '#844', '#484', '#448', '#848', '#884', '#488', '#444', '#888', '#fa0', '#af0', '#0af', '#0fa', '#a0f', '#f0a']);

    dailyLine.Set('chart.key', chartKey);
    dailyLine.Set('chart.labels', chartLabels);
        
    dailyLine.Set('chart.key.shadow', true);
    dailyLine.Set('chart.key.shadow.offsetx', 0);
    dailyLine.Set('chart.key.shadow.offsety', 0);
    dailyLine.Set('chart.key.shadow.blur', 15);
    dailyLine.Set('chart.key.shadow.color', '#ddd');
    dailyLine.Set('chart.key.rounded', false);
    dailyLine.Set('chart.key.position', 'graph');
    dailyLine.Set('chart.key.position.x', dailyLine.Get('chart.gutter') + 10);
    dailyLine.Set('chart.key.position.y', 40);
    dailyLine.Draw();
}
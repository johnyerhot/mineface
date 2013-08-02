# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
#= require highcharts
#= require modules/exporting

window._chartRefreshInterval = 30
window._chartRefreshTime = 0

$ ->
  window.refreshChart = (time = 0, manual = false)->
    dif = if time == 0 then 0 else (time - window._chartRefreshTime) % window._chartRefreshInterval
    return unless dif == 0 or manual
    window._chartRefreshTime = window.time
    chart.showLoading() if manual
    chartdata = charts[chartsel.val()]
    $.get('/chart', chartdata,(data, status, xhr) ->
      chart.setTitle({text: data.title })
      chart.xAxis[0].setExtremes(data.start, new Date().getTime(), false)

      if chart.series.length == 0
        chart.addSeries({}, false)
      chart.series[0].setData(data.data)
      chart.hideLoading()
    , 'json').fail (data) ->
      bootstrapAlert('chart_err', "#{data.status} #{data.statusText}", 'Failed to load chart data')

  chartsel.change ->
    refreshChart(0, true)
    sset('selected_chart', chartsel.val())

  addRefreshFunction(refreshChart)

  chartsel.val(sget('selected_chart', 0))
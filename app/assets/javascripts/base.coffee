######################################
# All events related to jQuery
@bonsai =
  presicion: 2
  separator: ','
  delimiter: '.'

########################################
# Init function
init = ($) ->
  # Regional settings for jquery-ui datepicker
  $.datepicker.regional['es'] = {
    closeText: 'Cerrar',
    prevText: '&#x3c;Ant',
    nextText: 'Sig&#x3e;',
    currentText: 'Hoy',
    monthNames: ['Enero','Febrero','Marzo','Abril','Mayo','Junio',
    'Julio','Agosto','Septiembre','Octubre','Noviembre','Diciembre'],
    monthNamesShort: ['Ene','Feb','Mar','Abr','May','Jun',
    'Jul','Ago','Sep','Oct','Nov','Dic'],
    dayNames: ['Domingo','Lunes','Martes','Mi&eacute;rcoles','Jueves','Viernes','S&aacute;bado'],
    dayNamesShort: ['Dom','Lun','Mar','Mi&eacute;','Juv','Vie','S&aacute;b'],
    dayNamesMin: ['Do','Lu','Ma','Mi','Ju','Vi','S&aacute;'],
    weekHeader: 'Sm',
    dateFormat: 'dd/mm/yy',
    firstDay: 1,
    isRTL: false,
    showMonthAfterYear: false,
    yearSuffix: ''
  }
  $.datepicker.setDefaults($.datepicker.regional['es'])

  # Effect fro dropdown
  initjDropDown = ->
    $(this).find('li').bind 'mouseover mouseout', (event)->
      if event.type == 'mouseover'
        $(this).addClass('marked')
      else
        $(this).removeClass('marked')
  $.initjDropDown = $.fn.initjDropDown = initjDropDown

  # Speed in milliseconds
  speed = 300
  # Date format
  $.datepicker._defaults.dateFormat = 'dd M yy'

  ##################################################

  # Ajax preloader content
  AjaxLoadingHTML = ->
    "<h4 class='c'><img src='/assets/ajax-loader.gif' alt='Cargando..' /> Cargando...</h4>"

  # Creates the dialog container
  @createDialog = (params) ->
    data = params
    params = _.extend({
      'id': new Date().getTime(), 'title': '', 'width': 800, 'modal': true, 'resizable' : false, 'position': 'top',
      #'close': (e, ui) ->
        #e.stopInmidiatePropagation()
        #e.preventDefault()
        #ui.remove()
        #$('.ui-widget-overlay').remove()
        ##$('#' + div_id ).parents("[role=dialog]").detach()
    }, params)
    html = params['html'] || AjaxLoadingHTML()
    div_id = params.id
    div = document.createElement('div')
    css = "ajax-modal " + params['class'] || ""
    $div = $(div)
    $div.attr( { 'id': params['id'], 'title': params['title'] } ).data(data)
    .addClass(css).css( { 'z-index': 10000 } ).html(html)
    delete(params['id'])
    delete(params['title'])

    $div.dialog( params )

    $div

  ########################################
  # Presents any link url in a modal dialog and loads with AJAX the url
  $('body').on('click', 'a.ajax', (event) ->
    event.preventDefault()

    id = new Date().getTime().toString()
    $this = $(this)
    $this.data('ajax_id', id)

    $div = createDialog( { 'title': $this.data('title'), 'new_record': $this.hasClass('new') } )
    $div.load( $this.attr("href"), (resp, status, xhr, dataType) ->
      $this = $(this)
      $tit = $this.dialog('widget').find('.ui-dialog-title')
      .text($('<div>').html(resp).find('h1').text())

      $div.setDatepicker()
    )
    event.stopPropagation()
  )

  # Delete an Item from a list, deletes a tr or li
  # Very important with default fallback for trigger
  $('body').on('click', 'a.delete[data-remote=true]', (e)->
    self = this
    $(self).parents("tr:first, li:first").addClass('marked')
    trigger = $(self).data('trigger') || 'ajax:delete'

    conf = $(self).data('confirm') || 'Esta seguro de borrar el item seleccionado'

    if(confirm(conf))
      url = $(this).attr('href')
      el = this
      $.ajax(
        'url': url
        'type': 'delete'
        'context': el
        'data': {'authenticity_token': csrf_token }
        'success': (resp, status, xhr)->
          if typeof resp == "object"
            if resp['destroyed?'] or resp.success
              $(el).parents("tr:first, li:first").remove()
              $('body').trigger(trigger, [resp, url])
            else
              $(self).parents("tr:first, li:first").removeClass('marked')
              error = resp.errors || ""
              alert("Error no se pudo borrar: #{error}")
          else if resp.match(/^\/\/\s?javascript/)
            $(self).parents("tr:first, li:first").removeClass('marked')
          else
            alert('Existio un error al borrar')
        'error': ->
          $(self).parents("tr:first, li:first").removeClass('marked')
          alert('Existio un error al borrar')
      )
    else
      $(this).parents("tr:first, li:first").removeClass('marked')
      e.stopPropagation()

    false
  )


  # Method to delete when it's in the .links in the top
  $('body').on('click', 'a.delete', (event) ->
    return false if $(this).attr("data-remote")

    txt = $(this).data("confirm") || "Esta seguro de borrar"
    unless confirm(txt)
      false
    else
      html = "<input type='hidden' name='utf-8' value='&#x2713;' />"
      html += "<input type='hidden' name='authenticity_token' value='#{csrf_token}' />"
      html += "<input type='hidden' name='_method' value='delete' />"

      form = $('<form/>').attr({'method': 'post', 'action': $(this).attr('href') })
      .html(html).appendTo('body').submit()

      false
  )

  # Mark
  # @param String // jQuery selector
  # @param Integer velocity
  mark = (selector, velocity, val) ->
    self = selector or this
    val = val or 0
    velocity = velocity or 50
    $(self).css({'background': 'rgb(255,255,'+val+')'})
    if(val >= 255)
      $(self).attr("style", "")
      return false
    setTimeout(->
      val += 5
      mark(self, velocity, val)
    , velocity)

  $.mark = $.fn.mark = mark

  # Adds a new link to any select with a data-new-url
  dataNewUrl = ->
    $(this).find('[data-new-url]').each((i, el) ->
      data = $.extend({width: 800}, $(el).data() )
      title = data.title || "Nuevo"

      $a = $('<a/>')
      css = {'margin-left': '5px'}
      #css['margin-top'] = '-9px' unless $a.prev().hasClass('select2-autocomplete')

      $a
      .html('<i class="icon-plus-sign icon-large"></i>')
      .attr({href: data.newUrl, class: 'ajax btn btn-small', title: title, rel: 'tooltip' })
      .data({trigger: data.trigger, width: data.width})
      .css(css)

      $a.insertAfter(el)
    )

  $.fn.dataNewUrl = dataNewUrl



  # Prevent enter submit forms in some forms
  window.keyPress = false
  $(document).on( 'keydown', 'form.enter input', (event) ->
    window.keyPress = event.keyCode || false
    true
  )

  # Closes the nearest div container
  $('body').on('click', 'a.close', ->
    self = this
    cont = $(this).parents('div:first').hide(speed)
    unless $(this).parents("div:first").hasClass("search")
      setTimeout ->
        cont.remove()
      ,speed
  )

  # Ajax configuration
  csrf_token = $('meta[name=csrf-token]').attr('content')
  window.csrf_token = csrf_token
  $.ajaxSetup(
    beforeSend: (xhr) ->
      xhr.setRequestHeader('X-CSRF-Token', csrf_token)
  )

########################################
# End of init function

########################################
# Start jquery
( ($) ->
  createErrorLog = (data) ->
    unless $('#error-log').length > 0
      $('<div id="error-log" style="background: #FFF"></div>')
      #.html("<iframe id='error-iframe' width='100%' height='100%'><body></body></iframe>")
      .dialog({title: 'Error', width: 900, height: 500})

    $('#error-log').html(data).dialog("open")

  # Creates a message window with the text passed
  # @param String: HTML to insert inside the message div
  # @param Object
  createMessageCont = (text, options)->
    "<div class='message'><a class='close' href='javascript:'>Cerrar</a>#{text}</div>"

  window.createMessageCont = createMessageCont



  # Supress from submiting a form from an input:text
  checkCR = (evt) ->
    evt  = evt  = (evt) ? evt : ((event) ? event : null)
    node = evt.target || evt.srcElement
    if evt.keyCode == 13 and node.type == "text" then false

  document.onkeypress = checkCR

  # For the modal forms and dialogs
  setTransformations = ->
    $(this).setDatepicker()
    $(this).createAutocomplete()

  $.fn.setTransformations = setTransformations

  # Template
  # Underscore templates
  _.templateSettings.interpolate = /\{\{(.+?)\}\}/g

  ########################################
  # Wrapped inside this working
  $(document).ready ->
    # Initializes
    init($)
    $('body').tooltip( selector: '[rel=tooltip]' )
    $('body').setDatepicker()
    $('body').createAutocomplete()
    $('.select2-autocomplete').select2Autocomplete()
    $('body').dataNewUrl()
    fx.rates = exchangeRates.rates
    

  rivets.configure(
    #preloadData: false
    adapter:
      subscribe: (obj, keypath, callback) ->
        obj.on('change:' + keypath, callback)
      unsubscribe: (obj, keypath, callback) ->
        obj.off('change:' + keypath, callback)
      read: (obj, keypath) ->
        obj.get(keypath)
      publish: (obj, keypath, value) ->
        obj.set(keypath, value)
  )

  rivets.formatters.number = (value) ->
    _b.ntc(value)

  rivets.formatters.currencyLabel = (val) ->
    if val?
      ['<span class="label label-inverse" title=',
        '"', currencies[val]['name'], '"', ' rel="tooltip">',
        val, '</span>'].join('')

  rivets.formatters.show = (val) ->
    if val
      'block'
    else
      'none'

  true
)(jQuery)

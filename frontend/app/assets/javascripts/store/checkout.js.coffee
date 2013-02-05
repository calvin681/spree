@disableSaveOnClick = ->
  ($ 'form.edit_order').submit ->
    ($ this).find(':submit, :image').attr('disabled', true).removeClass('primary').addClass 'disabled'

Spree.checkout = {}

$ ->
  if ($ '#checkout_form_address').is('*')
    ($ '#checkout_form_address').validate()

    country_id = ->
      $('p#' + region + 'country select').val()

    update_state = (region) ->
      if country_id != undefined
        if Spree.checkout[country_id] == undefined
          $.get Spree.routes.states_search + "/?country_id=#{country_id}", (data) ->
            Spree.checkout[country_id] = {}
            Spree.checkout[country_id]['states'] = data.states
            Spree.checkout[country_id]['states_required'] = data.states_required
            fill_in_states(Spree.checkout[country_id], region)
        else
          fill_in_states(Spree.checkout[country_id], region)

    fill_in_states = (data, region) ->
      states_required = data.states_required
      states = data.states

      state_para = ($ 'p#' + region + 'state')
      state_select = state_para.find('select')
      state_input = state_para.find('input')
      state_span_required = state_para.find('state-required')
      if states.length > 0
        selected = parseInt state_select.val()
        state_select.html ''
        states_with_blank = [{ name: '', id: ''}].concat(states)
        $.each states_with_blank, (idx, state) ->
          opt = ($ document.createElement('option')).attr('value', state.id).html(state.name)
          opt.prop 'selected', true if selected is state.id
          state_select.append opt

        state_select.prop('disabled', false).show()
        state_input.hide().prop 'disabled', true
        state_span_required.show()
      else
        state_select.hide().prop 'disabled', true
        state_input.show()
        if states_required
          state_span_required.show()
        else
          state_input.val ''
          state_span_required.hide()
        state_para.toggle(!!states_required)
        state_input.prop('disabled', !states_required)

    ($ 'p#bcountry select').change ->
      update_state 'b'

    ($ 'p#scountry select').change ->
      update_state 's'

    update_state 'b'
    update_state 's'

    ($ 'input#order_use_billing').click(->
      if ($ this).is(':checked')
        ($ '#shipping .inner').hide()
        ($ '#shipping .inner input, #shipping .inner select').prop 'disabled', true
      else
        ($ '#shipping .inner').show()
        ($ '#shipping .inner input, #shipping .inner select').prop 'disabled', false
        if Spree.checkout[country_id].states.length == 0
          ($ 'span#sstate input').hide().prop 'disabled', true
        else
          ($ 'span#sstate select').hide().prop 'disabled', true
    ).triggerHandler 'click'

  if ($ '#checkout_form_payment').is('*')
    ($ 'input[type="radio"][name="order[payments_attributes][][payment_method_id]"]').click(->
      ($ '#payment-methods li').hide()
      ($ '#payment_method_' + @value).show() if @checked
    )

    # Activate already checked payment method if form is re-rendered
    # i.e. if user enters invalid data
    ($ 'input[type="radio"]:checked').click()

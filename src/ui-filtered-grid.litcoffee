#filter-header
*TODO* tell me all about your element.

    Polymer 'filter-header',

##Attributes and Change Handlers

##Methods

        filterOpen : (event, detail, element)->
            columnName = @headerText

            event.stopPropagation()

            event.path.array().forEach (i) ->
                if i.nodeName == 'FILTER-HEADER'
                    if (@openModal?.opened)
                        @openModal.toggle()
                    i.$.modal.toggle()
                    @openModal = i.$.modal

        filter : ()->
            @job 'filterEntry', () ->
                value = @$.filterEntry.value
                if !value.trim()
                    return
                @$.filterEntry.value = ""
                @$.modal.toggle()
                @fire 'filter-on',
                    columnName: @headerText,
                    filterWord: value
            , 500

#table-header
*TODO* tell me all about your element.


    Polymer 'table-header',

        bindPrePends: ->
            tableHeaderPrepends = @querySelector('[table-header-prepends]')
            tableHeaderPrepends.setAttribute 'id', 'table-header-prepends'

            if tableHeaderPrepends
                @shadowRoot.appendChild tableHeaderPrepends

        attached: ->
            @readyBind = true

        ready: ->
            @itemCount = 0

#ui-filtered-grid
*TODO* tell me all about your element.


    Polymer 'ui-filtered-grid',

##Events
*TODO* describe the custom event `name` and `detail` that are fired.

##Attributes and Change Handlers

##Methods

        dataSrcChanged: () ->
            if !@$.table.classList.contains('loading')
                @$.table.classList.add('loading')
            @$.table.src = @dataSrc

        valueChanged: () ->
            @$.table.value = @value
            @updateHeader()

        filterValue: () ->
            _this = this
            tempVal = []

            @value.forEach (i) ->
                matchFound = true
                _this.filterWords.forEach (item) ->
                    temp = i[item.column]

                    if typeof(temp) is 'number'
                        temp = temp?.toString()

                    if matchFound and temp?.toLowerCase().indexOf(item.text.toLowerCase()) > -1
                        matchFound = true
                    else
                        matchFound = false

                if matchFound
                    tempVal.push i

            if (tempVal.length < 1)
                emptyVal = {}
                Object.keys(@value[0]).forEach (key) ->
                    emptyVal[key] = "Not Found"
                tempVal.push emptyVal

            @$.table.value = tempVal

        updateHeader: ->
            @$.table.classList.remove('loading')
            @filterValue()
            
            isNull = Object.keys(@$.table.value[0]).every (key) =>
                if (@$.table.value[0][key] isnt "Not Found")
                    return false
                return true
            
            if isNull
                @$.header.itemCount = 0
            else
                @$.header.itemCount = @$.table.value.length

            @$.header.pillList = @filterWords

        updateTable: ->
            if !@value
                @value = @$.table.value

        filter: (event, detail, element) ->
            @filterWords.forEach (i) ->
                if i.column == event.detail.columnName and i.text == event.detail.filterWord
                    return false

            @filterWords.push
                "column": event.detail.columnName,
                "text": event.detail.filterWord,
                "id": @filterWords.length

            @updateHeader()


        reFilter: (event, detail, element) ->
            @filterWords = @filterWords.filter (item) ->
                if item.id isnt event.detail.id
                    item

            @updateHeader()

##Polymer Lifecycle

        ready: ->
            columnOverrides = @querySelectorAll('[column-override]')

            columnOverrides.array().forEach (i) =>
                @shadowRoot.querySelector('ui-grid').appendChild i

            tableHeaderPrepends = @querySelector('[table-header-prepends]')

            if tableHeaderPrepends
                @shadowRoot.querySelector('#header').appendChild tableHeaderPrepends
                @$.header.bindPrePends()

            columnOverrides.array().forEach (i) =>
                @shadowRoot.querySelector('ui-grid').appendChild i

            @filterWords = []

            defFilters = []

            @defaultFilter?.split(',').forEach (i) =>
                defFilters.push i.trim()

            defFilters?.forEach (i) =>
                filterTokens = []
                i.split(':').forEach (item) =>
                    filterTokens.push item.trim()

                @filterWords.push
                    "column": filterTokens[0],
                    "text": filterTokens[1],
                    "id": @filterWords.length

            if @dataSrc
                @$.table.src = @dataSrc

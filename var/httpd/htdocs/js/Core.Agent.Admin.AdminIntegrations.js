"use strict";

var Core = Core || {};
Core.Agent = Core.Agent || {};
Core.Agent.Admin = Core.Agent.Admin || {};

new Vue({
    el: '#app',
    vuetify: new Vuetify(),
    data: () => {
      
      return {
        headers:[
            {
                text: 'Integração',
                align: 'left',
                sortable: false,
                value: 'Title',
              },
              { text: 'Status', value: 'status', sortable: false },
              { text: 'Action', value: 'action', sortable: false },
        ],
        integrations: []
    }},
    watch: {
      options: {
        handler () {
          this.getDataFromApi()
            .then(data => {
              this.integrations = data
            })
        },
        deep: true,
      },
    },
    mounted () {
      this.getDataFromApi()
        .then(data => {
          this.integrations = data
        })
    },
    methods: {
      getDataFromApi () {
        return new Promise((resolve, reject) => {
          var Data = {
            Action: 'AdminIntegrations',
            Subaction: 'GetIntegrationList'
          };
    
          console.log("Core",Core);
    
          Core.AJAX.FunctionCall(Core.Config.Get('CGIHandle'), Data, function (Response) {
            resolve(
              Response
            )
          });
        });
      }
    }
})
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
                text: 'Integrações',
                align: 'left',
                sortable: false,
                value: 'Title',
              },
              { text: 'Status', value: 'status', sortable: false },
              { text: 'Action', value: 'action', sortable: false },
        ],
        integrations: [],
        cards: [
          { title: 'Pre-fab homes', src: 'https://cdn.vuetifyjs.com/images/cards/house.jpg', flex: 3 },
          { title: 'Favorite road trips', src: 'https://cdn.vuetifyjs.com/images/cards/road.jpg', flex: 3 },
          { title: 'Best airlines', src: 'https://cdn.vuetifyjs.com/images/cards/plane.jpg', flex: 3 },
          { title: 'Best airlines 2', src: 'https://cdn.vuetifyjs.com/images/cards/plane.jpg', flex: 3 },
        ]
    }},
    watch: {
      options: {
        handler () {
          this.getDataFromApi()
            .then(data => {
              this.integrations = data;
              this.cards = data;
            })
        },
        deep: true,
      },
    },
    mounted () {
      this.getDataFromApi()
        .then(data => {
          this.integrations = data;
          this.cards = data;
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
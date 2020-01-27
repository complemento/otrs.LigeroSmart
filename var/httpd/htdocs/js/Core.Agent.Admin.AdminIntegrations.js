"use strict";



var Core = Core || {};
Core.Agent = Core.Agent || {};
Core.Agent.Admin = Core.Agent.Admin || {};

Vue.component('component-a', { template: '<p>AAAA</p>' })


Core.Vue = new Vue({
    el: '#app',
    vuetify: new Vuetify(),
    data: () => {
      
      return {
        dialog: false,  
        cards: [],
        integrationName: "",
        component: 'component-a'
    }},
    watch: {
      options: {
        handler () {
          this.getDataFromApi()
            .then(data => {
              this.cards = data;
              for (const a of this.cards) {
                Vue.component(a.IntegrationId, { template: a.Template, data () {
                  return {
                    e6: 1,
                  }
                }, });
              }
            })
        },
        deep: true,
      },
    },
    mounted () {
      this.getDataFromApi()
        .then(data => {
          this.cards = data;
          for (const a of this.cards) {
            Vue.component(a.IntegrationId, { template: a.Template, data () {
      return {
        e6: 1,
      }
    }, });
          }
          
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
      },
      openConfiguration (IntegrationId) {
        if(IntegrationId == undefined){
          this.component = 'component-a'
        } else {
          this.component = IntegrationId
        }
      }
    }
})


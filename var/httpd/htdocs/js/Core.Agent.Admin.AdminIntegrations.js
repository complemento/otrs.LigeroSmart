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
        component: 'component-a',
        updating: false,
        snackbar: false,
        text: '',
    }},
    watch: {
      options: {
        handler () {
          this.updating = true;
          this.getDataFromApi()
            .then(data => {
              this.cards = data;
              this.updating = false;
              for (const a of this.cards) {
                this.updating = true;
                a.TemplateData.then(val =>{
                  this.updating = false;
                  a.Enable = val.Enable;
                  Vue.component(a.IntegrationId, 
                    { 
                      template: val.Template, 
                      data () {
                        return val.DataStructure
                      },
                      methods: {
                        doConfigure(){
                          console.log("Cliquei no configure",this.data)
                        }
                      } 
                    });
                });
              }
            })
        },
        deep: true,
      },
    },
    mounted () {
      this.updating = true;
      this.getDataFromApi()
        .then(data => {
          this.cards = data;
          this.updating = false;
          for (const a of this.cards) {
            this.updating = true;
            a.TemplateData.then(val =>{
              this.updating = false;
              a.Enable = val.Enable;
              val.DataStructure.Module = a.Module;
              Vue.component(a.IntegrationId, 
                { 
                  template: val.Template, 
                  data () {
                    return val.DataStructure
                  },
                  methods: {
                    doConfigure(){
                      var Data = {
                        Action: this._data.Module,
                        Subaction: 'SendConfigData',
                        Data: JSON.stringify(this._data)
                      };
                      console.log("Cliquei no configure",this._data.field1)
                      new Promise((resolve, reject) => {
                        Core.AJAX.FunctionCall(Core.Config.Get('CGIHandle'), Data, function (Response) {
                          resolve(
                            Response
                          )
                        })
                      }).then(val => {
                        Core.Vue.$data.snackbar = true;
                        if(val.Result == 1){
                          Core.Vue.$data.text = "Save with success";
                          Object.assign(this.$data, val.Data);
                          Core.Vue.$data.dialog = false;
                        } else {
                          Core.Vue.$data.text = "Fail to save";
                        }
                      });
                    }
                  } 
                });
            });
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

          Core.AJAX.FunctionCall(Core.Config.Get('CGIHandle'), Data, function (Response) {
            for (const integration of Response) {
              Data = {
                Action: integration.Module,
                Subaction: 'GetTemplateData'
              };
              integration.TemplateData = new Promise((resolve, reject) => {
                Core.AJAX.FunctionCall(Core.Config.Get('CGIHandle'), Data, function (Response) {
                  resolve(
                    Response
                  )
                })
              });
              
            }
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
      },
      doActivate(card){
        this.updating = true;

        var Data = {
          Action: card.Module,
          Subaction: 'SetEnable',
          Value: card.Enable? "1": "0"
        };

        new Promise((resolve, reject) => {
          Core.AJAX.FunctionCall(Core.Config.Get('CGIHandle'), Data, function (Response) {
            resolve(Response)
          });
        }).then(value => {
          this.snackbar = true;
          if(value == 1){
            this.text = "Save with success";
          } else {
            this.text = "Fail to save";
          }
          this.updating = false;
        });
        
        
        console.log(card);
      }
    }
})


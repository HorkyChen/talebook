<template>
    <v-row align=start>
        <v-col cols=12>
            <v-card>
                <v-toolbar dark color="primary">
                    <v-toolbar-title align-center>{{ $t('book.edit.title') }}</v-toolbar-title>
                    <v-spacer></v-spacer>
                    <v-btn class='mr-2' color='red' :to="'/book/'+book.id">{{ $t('book.edit.cancel') }}</v-btn>
                    <v-btn color='green' @click="save_book">{{ $t('book.edit.save') }}</v-btn>
                </v-toolbar>
                <v-card-text class="pa-0 pa-md-2">
                    <v-form>
                        <v-container>
                            <v-row>
                                <v-col class='py-0' cols=12 sm=6>
                                    <v-text-field :label="$t('book.edit.fields.title')" v-model="book.title">{{ book.title }}</v-text-field>
                                </v-col>
                                <v-col class='py-4' cols=12 sm=6>
                                    <v-rating :label="$t('book.edit.fields.rating')" v-model="book.rating" color="yellow accent-4" length="10"
                                              dense></v-rating>
                                </v-col>
                                <v-col class='py-0' cols=12 sm=6>
                                    <!-- AUTHORS -->
                                    <v-combobox v-model="book.authors" :items="book.authors" :label="$t('book.edit.fields.authors')"
                                                :search-input.sync="author_input" hide-selected multiple small-chips>
                                        <template v-slot:no-data>
                                            <v-list-item>
                                                <span v-if="! author_input">{{ $t('book.edit.fields.authors.noData') }}</span>
                                                <div v-else>
                                                    <span class="subheading">{{ $t('book.edit.fields.authors.add') }}</span>
                                                    <v-chip color="green lighten-3" label small rounded> {{
                                                            author_input
                                                        }}
                                                    </v-chip>
                                                </div>
                                            </v-list-item>
                                        </template>
                                        <!-- author chip & close -->
                                        <template v-slot:selection="{ attrs, item, parent, selected }">
                                            <v-chip v-bind="attrs" color="green lighten-3" :input-value="selected" label
                                                    small>
                                                <span class="pr-2"> {{ item }} </span>
                                                <v-icon small @click="parent.selectItem(item)">close</v-icon>
                                            </v-chip>
                                        </template>
                                    </v-combobox>
                                </v-col>
                                <v-col class='py-0' cols=12 sm=6>
                                    <v-text-field :label="$t('book.edit.fields.series')" v-model="book.series">{{ book.series }}</v-text-field>
                                </v-col>
                                <v-col class='py-0' cols=12 sm=6>
                                    <v-text-field :label="$t('book.edit.fields.publisher')" v-model="book.publisher">{{ book.publisher }}
                                    </v-text-field>
                                </v-col>
                                <v-col class='py-0' cols=12 sm=6>
                                    <v-text-field :label="$t('book.edit.fields.pubdate')" v-model="book.pubdate">{{ book.pubdate }}</v-text-field>
                                </v-col>
                                <v-col class='py-0' cols=12 sm=6>
                                    <v-text-field :label="$t('book.edit.fields.isbn')" v-model="book.isbn">{{ book.isbn }}</v-text-field>
                                </v-col>
                                <v-col class='py-0' cols=12 sm=6>
                                    <v-text-field :label="$t('book.edit.fields.language')" v-model="book.language">{{ book.language }}</v-text-field>
                                </v-col>
                                <v-col class='py-0' cols=12>
                                    <!-- TAGS -->
                                    <v-combobox v-model="book.tags" :items="book.tags" :label="$t('book.edit.fields.tags')"
                                                :search-input.sync="tag_input" hide-selected multiple small-chips>
                                        <template v-slot:no-data>
                                            <v-list-item>
                                                <span v-if="! tag_input">{{ $t('book.edit.fields.tags.noData') }}</span>
                                                <div v-else>
                                                    <span class="subheading">{{ $t('book.edit.fields.tags.add') }}</span>
                                                    <v-chip color="green lighten-3" label small rounded> {{
                                                            tag_input
                                                        }}
                                                    </v-chip>
                                                </div>
                                            </v-list-item>
                                        </template>
                                        <!-- tag chip & close -->
                                        <template v-slot:selection="{ attrs, item, parent, selected }">
                                            <v-chip v-bind="attrs" color="green lighten-3" :input-value="selected" label
                                                    small>
                                                <span class="pr-2"> {{ item }} </span>
                                                <v-icon small @click="parent.selectItem(item)">close</v-icon>
                                            </v-chip>
                                        </template>
                                    </v-combobox>
                                </v-col>
                                <v-col class='py-0' cols="12">
                                    <v-textarea small outlined rows="15" :label="$t('book.edit.fields.comments')" v-model="book.comments"
                                                :value="book.comments"></v-textarea>
                                </v-col>
                                <v-divider></v-divider>
                                <v-col align=center cols="12">
                                    <v-btn dark color='green' @click='save_book'>{{ $t('book.edit.save') }}</v-btn>
                                </v-col>
                            </v-row>
                        </v-container>

                    </v-form>
                </v-card-text>
            </v-card>
        </v-col>
    </v-row>
</template>

<script>
export default {
    components: {},
    computed: {
        pub_year: function () {
            if (this.book === null) {
                return "";
            }
            return this.book.pubdate.split("-")[0];
        },
    },
    data: () => ({
        bookid: 0,
        book: {'id': 0, 'files': [], 'tags': [], 'pubdate': ''},
        author_input: null,
        tag_input: null,
        debug: false,
        mail_to: "",
        dialog_kindle: false,
        dialog_msg: false,
        alert_msg: "please login",
        alert_type: "error",
    }),
    async asyncData({params, app, res}) {
        if (res !== undefined) {
            res.setHeader('Cache-Control', 'no-cache');
        }
        return app.$backend("/book/" + params.bid);
    },
    head() {
        return {
            title: "编辑 " + this.book.title,
        }
    },
    created() {
        //this.$store.commit('navbar', true);
        //this.init(this.$route);
    },
    beforeRouteUpdate(to, from, next) {
        this.init(to, next);
    },
    methods: {
        init(route, next) {
            //this.$store.commit('navbar', true);
            this.bookid = this.$route.params.bid;
            this.$backend("/book/" + this.bookid)
                .then(rsp => {
                    this.book = rsp.book;
                });
            if (next) next();
        },
        save_book() {
            this.saving = true;
            this.$backend("/book/" + this.book.id + "/edit", {
                method: "POST",
                body: JSON.stringify(this.book),
            })
                .then(rsp => {
                    if (rsp.err === 'ok') {
                        this.$alert("success", "保存成功！");
                        this.$router.push("/book/" + this.book.id);
                    } else {
                        this.$alert("error", rsp.msg);
                    }
                });
        }
    },
}
</script>

<style>
.align-right {
    text-align: right;
}

.book-footer {
    padding-top: 0;
    padding-bottom: 3px;
}

.tag-chips a {
    margin: 4px 2px;
}
</style>
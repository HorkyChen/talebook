<template>
    <v-card>
        <v-card-title> {{ $t('admin.books.title') }} <v-chip small class="primary">Beta</v-chip> </v-card-title>
        <v-card-text> {{ $t('admin.books.description') }} </v-card-text>
        <v-card-actions>
            <v-btn :disabled="loading" outlined color="primary" @click="getDataFromApi"><v-icon>mdi-reload</v-icon>{{ $t('admin.books.refresh') }}</v-btn>
            <v-btn :disabled="loading" outlined color="info" @click="show_dialog_auto_file"><v-icon>mdi-info</v-icon>{{ $t('admin.books.autoUpdate') }}</v-btn>
            <v-btn :disabled="loading || books_selected.length === 0" outlined color="info" @click="deleteSelectedBooks"><v-icon>mdi-info</v-icon>{{ $t('admin.books.deleteSelected') }}</v-btn>
            <v-spacer></v-spacer>
            <v-text-field cols="2" dense @keyup.enter="getDataFromApi" v-model="search" append-icon="mdi-magnify" :label="$t('admin.books.search')" single-line hide-details></v-text-field>
        </v-card-actions>
        <v-data-table
            dense
            class="elevation-1 text-body-2"
            show-select
            v-model="books_selected"
            item-key="id"
            :search="search"
            :headers="headers"
            :items="items"
            :options.sync="options"
            :server-items-length="total"
            :loading="loading"
            :items-per-page="100"
            :footer-props="{ 'items-per-page-options': [10, 50, 100] }"
        >
            <template v-slot:item.status="{ item }">
                <v-chip small v-if="item.status == 'ready'" class="success">{{ $t('admin.books.status.ready') }}</v-chip>
                <v-chip small v-else-if="item.status == 'exist'" class="lighten-4">{{ $t('admin.books.status.exist') }}</v-chip>
                <v-chip small v-else-if="item.status == 'imported'" class="primary">{{ $t('admin.books.status.imported') }}</v-chip>
                <v-chip small v-else-if="item.status == 'new'" class="grey">{{ $t('admin.books.status.new') }}</v-chip>
                <v-chip small v-else class="info">{{ item.status }}</v-chip>
            </template>
            <template v-slot:item.img="{ item }">
                <a target="_blank" :href="item.img"><v-img :src="item.thumb" class="my-1" max-height="80"  :aspect-ratio="3/4" /></a>
            </template>
            <template v-slot:item.id="{ item }">
                <a target="_blank" :href="`/book/${item.id}`">{{ item.id }}</a>
            </template>
            <template v-slot:item.title="{ item }">
                <v-edit-dialog large :return-value.sync="item.title" @save="save(item, 'title')" save-text="保存" cancel-text="取消">
                    <span class="three-lines" style="max-width: 200px; min-width: 120px; ">{{ item.title }}</span>

                    <template v-slot:input>
                        <div class="mt-4 text-h6">修改字段</div>
                        <v-textarea v-model="item.title" label="书名" style="min-width: 400px" counter></v-textarea>
                    </template>
                </v-edit-dialog>
            </template>

            <template v-slot:item.author="{ item }">
                <v-edit-dialog large :return-value.sync="item.author" @save="save(item, 'authors')" save-text="保存" cancel-text="取消">
                    <span class="three-lines" style="max-width: 200px" v-if="item.authors">{{ item.authors.join("/") }}</span>
                    <span v-else> - </span>
                    <template v-slot:input>
                        <!-- AUTHORS -->
                        <div class="mt-4 text-h6">修改字段</div>
                        <v-combobox
                            v-model="item.authors"
                            :items="item.authors"
                            label="作者"
                            :search-input.sync="tag_input"
                            hide-selected
                            multiple
                            small-chips
                        >
                            <template v-slot:no-data>
                                <v-list-item>
                                    <span v-if="!tag_input">请输入新的名称</span>
                                    <div v-else>
                                        <span class="subheading">添加</span>
                                        <v-chip color="green lighten-3" label small rounded> {{ tag_input }} </v-chip>
                                    </div>
                                </v-list-item>
                            </template>
                            <!-- tag chip & close -->
                            <template v-slot:selection="{ attrs, item, parent, selected }">
                                <v-chip v-bind="attrs" color="green lighten-3" :input-value="selected" label small>
                                    <span class="pr-2"> {{ item }} </span>
                                    <v-icon small @click="parent.selectItem(item)">close</v-icon>
                                </v-chip>
                            </template>
                        </v-combobox>
                    </template>
                </v-edit-dialog>
            </template>

            <template v-slot:item.rating="{ item }">
                <v-edit-dialog large :return-value.sync="item.rating" @save="save(item, 'rating')" save-text="保存" cancel-text="取消">
                    <span v-if="item.rating != null">{{ item.rating }} 星</span>
                    <span v-else> - </span>
                    <template v-slot:input>
                        <div class="mt-4 text-h6">修改字段</div>
                        <v-rating label="评分" v-model="item.rating" color="yellow accent-4" length="10" dense></v-rating>
                    </template>
                </v-edit-dialog>
            </template>

            <template v-slot:item.publisher="{ item }">
                <v-edit-dialog
                    large
                    :return-value.sync="item.publisher"
                    @save="save(item, 'publisher')"
                    save-text="保存"
                    cancel-text="取消"
                >
                    {{ item.publisher }}
                    <template v-slot:input>
                        <div class="mt-4 text-h6">修改字段</div>
                        <v-text-field v-model="item.publisher" label="出版社" counter></v-text-field>
                    </template>
                </v-edit-dialog>
            </template>

            <template v-slot:item.tags="{ item }">
                <v-edit-dialog large :return-value.sync="item.tags" @save="save(item, 'tags')" save-text="保存" cancel-text="取消">
                    <span style="width: 200px" class="three-lines" v-if="item.tags">{{ item.tags.join("/") }}</span>
                    <span v-else> - </span>
                    <template v-slot:input>
                        <!-- TAGS -->
                        <div class="mt-4 text-h6">修改字段</div>
                        <v-combobox
                            v-model="item.tags"
                            :items="item.tags"
                            label="标签列表"
                            :search-input.sync="tag_input"
                            hide-selected
                            multiple
                            small-chips
                        >
                            <template v-slot:no-data>
                                <v-list-item>
                                    <span v-if="!tag_input">请输入新的标签名称</span>
                                    <div v-else>
                                        <span class="subheading">添加标签</span>
                                        <v-chip color="green lighten-3" label small rounded> {{ tag_input }} </v-chip>
                                    </div>
                                </v-list-item>
                            </template>
                            <!-- tag chip & close -->
                            <template v-slot:selection="{ attrs, item, parent, selected }">
                                <v-chip v-bind="attrs" color="green lighten-3" :input-value="selected" label small>
                                    <span class="pr-2"> {{ item }} </span>
                                    <v-icon small @click="parent.selectItem(item)">close</v-icon>
                                </v-chip>
                            </template>
                        </v-combobox>
                    </template>
                </v-edit-dialog>
            </template>

            <template v-slot:item.comments="{ item }">
                <v-edit-dialog large :return-value.sync="item.comments" @save="save(item, 'comments')" save-text="保存" cancel-text="取消">
                    <span :title="item.comments" style="width: 300px" class="three-lines">{{ item.comments.substr(0, 80) }}</span>
                    <template v-slot:input>
                        <div class="mt-4 text-h6">修改字段</div>
                        <v-textarea v-model="item.comments" label="简介"></v-textarea>
                    </template>
                </v-edit-dialog>
            </template>

            <template v-slot:item.actions="{ item }">
                <v-menu offset-y right>
                    <template v-slot:activator="{ on }">
                        <v-btn color="primary" small v-on="on">操作 <v-icon small>more_vert</v-icon></v-btn>
                    </template>
                    <v-list dense>
                        <v-list-item @click="delete_book(item)">
                            <v-list-item-title>删除此书</v-list-item-title>
                        </v-list-item>
                    </v-list>
                </v-menu>
            </template>
        </v-data-table>

        <!-- 小浮窗提醒 -->
        <v-snackbar v-model="snack" top :timeout="3000" :color="snackColor">
            {{ snackText }}

            <template v-slot:action="{ attrs }">
                <v-btn v-bind="attrs" text @click="snack = false"> {{ $t('admin.books.close') }} </v-btn>
            </template>
        </v-snackbar>

        <!-- 提醒拉取图书的规则说明 -->
        <v-dialog v-model="meta_dialog" persistent transition="dialog-bottom-transition" width="500">
            <v-card>
                <v-toolbar flat dense dark color="primary"> {{ $t('admin.books.reminderTitle') }} </v-toolbar>
                <v-card-title></v-card-title>
                <v-card-text>
                    <p> {{ $t('admin.books.reminder.description') }} </p>
                    <p> {{ $t('admin.books.reminder.rule1') }} </p>
                    <p> {{ $t('admin.books.reminder.rule2') }} </p>
                    <p> {{ $t('admin.books.reminder.rule3') }} </p>
                    <br></br>
                    <template v-if="progress.total > 0">
                        <p>{{ $t('admin.books.reminder.progress') }}<v-btn small text link @click="refresh_progress">{{ $t('admin.books.refresh') }}</v-btn></p>
                        <p>{{ $t('admin.books.reminder.progressDetails', { total: progress.total, done: progress.done, fail: progress.fail, skip: progress.skip }) }}</p>
                    </template>
                    <p v-else> {{ $t('admin.books.reminder.estimate', { minutes: auto_fill_mins }) }} </p>

                    <template v-else>

                    </template>
                </v-card-text>
                <v-card-actions>
                    <v-btn @click="meta_dialog = !meta_dialog">{{ $t('admin.books.cancel') }}</v-btn>
                    <v-spacer></v-spacer>
                    <v-btn color="primary" @click="auto_fill">{{ $t('admin.books.execute') }}</v-btn>
                </v-card-actions>
            </v-card>
        </v-dialog>

</v-card>
</template>

<script>
export default {
    data: () => ({
        snack: false,
        snackColor: "",
        snackText: "",
        meta_dialog: false,

        books_selected: [],
        tag_input: null,
        search: "",
        page: 1,
        items: [],
        total: 0,
        loading: false,
        options: { sortBy: ["id"], sortDesc: [true] },
        headers: [
            { text: "封面", sortable: false, value: "img", width: "80px" },
            { text: "ID", sortable: true, value: "id", width: "80px" },
            { text: "书名", sortable: true, value: "title" },
            { text: "作者", sortable: true, value: "author", width: "100px" },
            { text: "评分", sortable: false, value: "rating", width: "60px" },
            { text: "出版社", sortable: false, value: "publisher" },
            { text: "标签", sortable: true, value: "tags", width: "100px" },
            { text: "简介", sortable: true, value: "comments" },
            { text: "操作", sortable: false, value: "actions" },
        ],
        progress: {
            skip: 0,
            fail: 0,
            done: 0,
            total: 0,
            status: "finish",
        },
    }),
    created() {},
    watch: {
        options: {
            handler() {
                this.getDataFromApi();
            },
            deep: true,
        },
    },
    computed: {
        auto_fill_mins: function() {
            return Math.floor(this.total/60) + 1;
        }
    },
    methods: {
        getDataFromApi() {
            this.loading = true;
            const { sortBy, sortDesc, page, itemsPerPage } = this.options;

            var data = new URLSearchParams();
            if (page != undefined) {
                data.append("page", page);
            }
            if (sortBy != undefined) {
                data.append("sort", sortBy);
            }
            if (sortDesc != undefined) {
                data.append("desc", sortDesc);
            }
            if (itemsPerPage != undefined) {
                data.append("num", itemsPerPage);
            }
            if (this.search != undefined) {
                data.append("search", this.search);
            }
            this.$backend("/admin/book/list?" + data.toString())
                .then((rsp) => {
                    if (rsp.err != "ok") {
                        this.items = [];
                        this.total = 0;
                        this.$alert("error", rsp.msg);
                        return false;
                    }
                    this.items = rsp.items;
                    this.total = rsp.total;
                })
                .finally(() => {
                    this.loading = false;
                });
        },
        deleteSelectedBooks() {
            if (this.books_selected.length == 0) {
                this.$alert("info", this.$t("admin.books.noSelectedBook"));
                return;
            }
            this.loading = true;
            const books_ids = this.books_selected.map((book) => {
                return book.id;
            });
            this.$backend("/admin/books/delete", {
                method: "POST",
                body: JSON.stringify({"idlist": books_ids}),
            })
                .then((rsp) => {
                    if (rsp.err != "ok") {
                        this.$alert("error", rsp.msg);
                    } else {
                        this.snack = true;
                        this.snackColor = "success";
                        this.snackText = rsp.msg;
                    }
                    this.books_selected = [];
                    this.getDataFromApi();
                })
                .finally(() => {
                    this.loading = false;
                });
        },
        refresh_progress() {
            this.$backend("/admin/book/fill", {
                method: "GET",
            })
            .then((rsp) => {
                this.progress = rsp.status;
            })
        },
        show_dialog_auto_file() {
            this.meta_dialog = true;
            this.refresh_progress();
        },
        auto_fill() {
            this.$backend("/admin/book/fill", {
                method: "POST",
                body: JSON.stringify({"idlist": "all"}),
            })
            .then((rsp) => {
                this.meta_dialog = false;
                if (rsp.err != "ok") {
                    this.$alert("error", rsp.msg);
                }
                this.snack = true;
                this.snackColor = "success";
                this.snackText = rsp.msg;
            })
        },
        delete_book(book) {
            this.loading = true;
            this.$backend("/book/" + book.id + "/delete", {
                method: "POST",
                body: "",
            })
                .then((rsp) => {
                    if (rsp.err != "ok") {
                        this.$alert("error", rsp.msg);
                    }
                    this.snack = true;
                    this.snackColor = "success";
                    this.snackText = rsp.msg;

                    this.getDataFromApi();
                })
                .finally(() => {
                    this.loading = false;
                });
        },
        save(book, field) {
            var edit = {};
            edit[field] = book[field];
            this.saving = true;
            this.$backend("/book/" + book.id + "/edit", {
                method: "POST",
                body: JSON.stringify(edit),
            }).then((rsp) => {
                if (rsp.err == "ok") {
                    this.snack = true;
                    this.snackColor = "success";
                    this.snackText = rsp.msg;
                } else {
                    this.$alert("error", rsp.msg);
                }
            });
        },
    },
};
</script>

<style>
.three-lines {
    overflow: hidden;
    text-overflow: ellipsis;
    display: -webkit-box;
    -webkit-box-orient: vertical;
    -webkit-line-clamp: 3;
    white-space: normal;
}
</style>

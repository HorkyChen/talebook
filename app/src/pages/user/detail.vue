<template>
    <v-form ref="form" @submit.prevent="save">
        <v-row align=start>
            <v-col cols=3><v-subheader class="pa-0 float-right">{{ $t('user.avatar') }}</v-subheader></v-col>
            <v-col cols=9>
                <v-img class="float-left" height=80 contain @click="showAvatarDialog = true" :src="user.avatar"></v-img>
                <v-dialog v-model="showAvatarDialog" persistent transition="dialog-bottom-transition" width="300">
                    <v-card>
                        <v-toolbar flat dense dark color="primary">
                            {{ $t('user.uploadAvatar') }}
                            <v-spacer></v-spacer>
                            <v-btn color="" text @click="showAvatarDialog = false">{{ $t('user.close') }}</v-btn>
                        </v-toolbar>
                        <v-card-title></v-card-title>
                        <v-card-text>
                            <p>{{ $t('user.uploadWarning') }}</p>
                            <v-form ref="form" @submit="do_upload">
                                <v-file-input v-model="image" accept="image/png,image/jpeg" :label="$t('user.uploadImage')" @change="onAvatarChange"></v-file-input>
                            </v-form>
                            <vue-cropper
                                v-if="avatarUrl"
                                ref="cropper"
                                :src="avatarUrl"
                                :aspect-ratio="1"
                                :view-mode="1"
                                :auto-crop-area="1"
                                style="width: 160px; height: 160px"
                            />
                        </v-card-text>
                        <v-card-actions>
                        <v-spacer></v-spacer>
                        <v-btn color="primary" @click="uploadAvatar">{{ $t('user.save') }}</v-btn>
                        <v-btn text @click="showAvatarDialog = false">{{ $t('user.cancel') }}</v-btn>
                        </v-card-actions>
                    </v-card>
                </v-dialog>
            </v-col>

            <v-col cols=3><v-subheader class="pa-0 float-right">{{ $t('user.username') }}</v-subheader></v-col>
            <v-col cols=9><p class="pt-3 mb-0">{{user.username}}</p></v-col>

            <v-col cols=3><v-subheader class="pa-0 float-right">{{ $t('user.email') }}</v-subheader></v-col>
            <v-col cols=9><p class="pt-3 mb-0">{{user.email}}<a href='#' v-if="!user.is_active" @click='send_active_email'>{{ $t('user.resendActivationEmail') }}</a></p></v-col>

            <v-col cols=3><v-subheader class="pa-0 float-right">{{ $t('user.password') }}</v-subheader></v-col>
            <v-col cols=9>
                <v-subheader class="pa-0" >
                    <a href="#" @click.stop="show_pass = ! show_pass">{{ $t('user.modifyPassword') }}</a>
                </v-subheader>
                <div v-if="show_pass">
                    <v-text-field solo v-model="user.password0" :label="$t('user.currentPassword')" type="password" autocomplete="new-password0" :rules="[rules.pass]" ></v-text-field>
                    <v-text-field solo v-model="user.password1" :label="$t('user.newPassword')"   type="password" autocomplete="new-password1" :rules="[rules.pass]" ></v-text-field>
                    <v-text-field solo v-model="user.password2" :label="$t('user.confirmPassword')" type="password" autocomplete="new-password2" :rules="[valid]"      ></v-text-field>
                </div>
            </v-col>

            <v-col cols=3><v-subheader class="pa-0 float-right">{{ $t('user.nickname') }}</v-subheader></v-col>
            <v-col cols=9> <v-text-field solo v-model="user.nickname" :label="$t('user.nickname')" type="text" autocomplete="new-nickname" :rules="[rules.nick]"></v-text-field> </v-col>

            <v-col cols=3><v-subheader class="pa-0 float-right">{{ $t('user.kindleAddress') }}</v-subheader></v-col>
            <v-col cols=9> <v-text-field solo v-model="user.kindle_email" :label="$t('user.kindle')" type="text" autocomplete="new-email" :rules="[rules.email]"></v-text-field> </v-col>
            <v-col cols=12>
                <div class="text-center">
                    <v-btn dark large rounded color="orange" @click="save">{{ $t('user.save') }}</v-btn>
                </div>
            </v-col>
        </v-row>
    </v-form>
</template>

<script>
import VueCropper from 'vue-cropperjs'
import 'cropperjs/dist/cropper.css'

export default {
    data: () => ({
        user: {},
        show_pass: false,
        rules: {
            pass: v => v == undefined || v.length == 0 || v.length >= 8 || 'Min 8 characters',
            nick: v => v == undefined || v.length == 0 || v.length >= 2 || 'Min 2 characters',
            email: function (email) {
                var re = /^(([^<>()[\]\\.,;:\s@"]+(\.[^<>()[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
                return email == undefined || email.length == 0 || re.test(email) || "Invalid email format";
            },
        },
        showAvatarDialog: false,
        avatarUrl: null,
    }),
    async asyncData({ params, app, res }) {
        if ( res !== undefined ) {
            res.setHeader('Cache-Control', 'no-cache');
        }
        return app.$backend("/user/info?detail=1");
    },
    head() {
        return { title: this.$t('user.user_center') };
    },
    created() {
        this.init(this.$route);
    },
    beforeRouteUpdate(to, from, next) {
        this.init(to, next);
    },
    methods: {
        valid: function(v) {
            return v == this.user.password1 || this.$t('user.passwordMismatch')
        },
        save: function() {
            if ( ! this.$refs.form.validate() ) {
                return false;
            }
            var d = {
                'password0': this.user.password0,
                'password1': this.user.password1,
                'password2': this.user.password2,
                'nickname': this.user.nickname,
                'kindle_email': this.user.kindle_email,
            }
            this.$backend('/user/update', {
                method: 'POST',
                body: JSON.stringify(d),
            })
            .then( rsp => {
                if ( rsp.err != 'ok' ) {
                    this.failmsg = rsp.msg;
                } else {
                    this.$store.commit("navbar", true);
                    this.$router.push("/");
                }
            });
        },
        send_active_email: function() {
            this.$backend('/user/active/send')
            .then( rsp => {
                if ( rsp.err == 'ok' ) {
                    this.$alert("success", this.$t('user.activationEmailSent'));
                } else {
                    this.$alert("danger", rsp.msg);
                }
            });
        },
        init(route, next) {
            this.$store.commit('navbar', true);
            this.$backend("/user/info?detail=1")
            .then( rsp => {
                rsp.user.password0 = "";
                rsp.user.password1 = "";
                rsp.user.password2 = "";
                this.user = rsp.user;
                this.avatarUrl = rsp.user.avatar;
                if (this.user.avatar) {
                    if (this.user.avatar.startsWith('http')) {
                        this.avatarUrl = this.user.avatar;
                    } else {
                        this.avatarUrl = this.site_url + this.user.avatar;
                    }
                    console.log("Avatar URL:", this.avatarUrl);
                } else {
                    this.avatarUrl = null; // 如果没有头像，清空URL
                }
            });
            if ( next ) next();
        },
        onAvatarChange(e) {
            const file = e.target.files[0];
            if (file && (file.type === "image/png" || file.type === "image/jpeg")) {
                this.avatarUrl = URL.createObjectURL(file);
            } else {
                this.$alert("error", "请上传PNG或JPEG格式图片");
            }
        },
        async uploadAvatar() {
            const canvas = this.$refs.cropper.getCroppedCanvas({ width: 96, height: 96, imageSmoothingQuality: 'high' });
            const blob = await new Promise(resolve => canvas.toBlob(resolve, 'image/png'));
            const formData = new FormData();
            formData.append('avatar', blob, 'avatar.png');
            this.$backend('/user/avatar', {
                method: 'POST',
                body: formData,
            }).then(rsp => {
                if (rsp.err === 'ok') {
                    this.user.avatar = rsp.avatar_url; // 后端返回新头像地址
                    this.showAvatarDialog = false;
                    this.$alert("success", "头像更新成功");
                } else {
                    this.$alert("error", rsp.msg);
                }
            });
        },
    },
}
</script>

<style></style>

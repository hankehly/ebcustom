<template>
    <v-app id="inspire">
        <v-app-bar app color="indigo" dark>
            <v-toolbar-title>Todo List</v-toolbar-title>
        </v-app-bar>
        <v-content>

            <v-data-table
                    :headers="headers"
                    :items="tasks"
                    sort-by="id"
                    class="elevation-1"
            >
                <template v-slot:top>
                    <v-toolbar flat color="white">
                        <v-toolbar-title>My Tasks</v-toolbar-title>
                        <v-divider
                                class="mx-4"
                                inset
                                vertical
                        ></v-divider>
                        <v-spacer></v-spacer>
                        <v-dialog v-model="dialog" max-width="500px">
                            <template v-slot:activator="{ on }">
                                <v-btn color="primary" dark class="mb-2" v-on="on">
                                    New Task
                                </v-btn>
                            </template>
                            <v-card>
                                <v-card-title>
                                    <span class="headline">{{ formTitle }}</span>
                                </v-card-title>

                                <v-card-text>
                                    <v-container>
                                        <v-row>
                                            <v-col cols="12" sm="6" md="4">
                                                <v-text-field v-model="editedItem.name"
                                                              label="Task name"></v-text-field>
                                            </v-col>
                                        </v-row>
                                    </v-container>
                                </v-card-text>

                                <v-card-actions>
                                    <v-spacer></v-spacer>
                                    <v-btn color="blue darken-1" text @click="close">
                                        Cancel
                                    </v-btn>
                                    <v-btn color="blue darken-1" text @click="save">
                                        Save
                                    </v-btn>
                                </v-card-actions>
                            </v-card>
                        </v-dialog>
                    </v-toolbar>
                </template>
                <template v-slot:item.action="{ item }">
                    <v-icon
                            small
                            class="mr-2"
                            @click="editItem(item)"
                    >
                        edit
                    </v-icon>
                    <v-icon
                            small
                            @click="deleteItem(item)"
                    >
                        delete
                    </v-icon>
                </template>
                <template v-slot:no-data>
                    <v-btn color="primary" @click="initialize">Reset</v-btn>
                </template>
            </v-data-table>

        </v-content>

        <v-footer color="indigo" app>
            <span class="white--text">&copy; 2019 - github.com/hankehly/ebcustom</span>
        </v-footer>
    </v-app>
</template>

<script>
    export default {
        name: 'App',
        props: {
            source: String,
        },
        data: () => ({
            dialog: false,
            headers: [
                {text: "Id", value: "id"},
                {text: 'Task', align: 'left', value: 'name'},
                {text: 'Actions', value: 'action', sortable: false},
            ],
            tasks: [],
            editedIndex: -1,
            editedItem: {
                name: '',
            },
            defaultItem: {
                name: '',
            },
        }),
        computed: {
            formTitle() {
                return this.editedIndex === -1 ? 'New Task' : 'Edit Task'
            },
        },
        watch: {
            dialog(val) {
                val || this.close()
            },
        },

        created() {
            this.initialize()
        },
        methods: {
            initialize() {
                this.tasks = [
                    {id: 1, name: 'Wash the dishes'},
                    {id: 2, name: 'Feed the cat'},
                    {id: 3, name: 'Do the laundry'},
                    {id: 4, name: 'Repair the car'},
                    {id: 5, name: 'Take out the track'},
                    {id: 6, name: 'Mop the floor'},
                    {id: 7, name: 'Clean the air filter'},
                    {id: 8, name: 'Shovel the driveway'},
                    {id: 9, name: 'Plan vacation'},
                ];
            },

            editItem(item) {
                this.editedIndex = this.tasks.indexOf(item);
                this.editedItem = Object.assign({}, item);
                this.dialog = true
            },

            deleteItem(item) {
                const index = this.tasks.indexOf(item);
                confirm('Are you sure you want to delete this task?') && this.tasks.splice(index, 1);
            },

            close() {
                this.dialog = false;
                setTimeout(() => {
                    this.editedItem = Object.assign({}, this.defaultItem);
                    this.editedIndex = -1;
                }, 300)
            },

            save() {
                if (this.editedIndex > -1) {
                    Object.assign(this.tasks[this.editedIndex], this.editedItem);
                } else {
                    this.tasks.push(this.editedItem);
                }
                this.close();
            },
        }
    }
</script>
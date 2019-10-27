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
                    sort-desc
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
            async initialize() {
                const response = await fetch('http://localhost:8000/tasks/');
                this.tasks = await response.json();
            },

            editItem(item) {
                this.editedIndex = this.tasks.indexOf(item);
                this.editedItem = Object.assign({}, item);
                this.dialog = true
            },

            async deleteItem(item) {
                if (!confirm('Are you sure you want to delete this task?')) {
                    return;
                }

                const index = this.tasks.indexOf(item);
                const response = await fetch(`http://localhost:8000/tasks/${item.id}`, {method: "delete"});

                if (response.ok) {
                    this.tasks.splice(index, 1);
                } else {
                    alert(`It looks like an error occurred: ${response.statusText}`);
                }
            },

            close() {
                this.dialog = false;
                setTimeout(() => {
                    this.editedItem = Object.assign({}, this.defaultItem);
                    this.editedIndex = -1;
                }, 300)
            },

            async save() {
                if (this.editedIndex > -1) {
                    const task = this.tasks[this.editedIndex];

                    const response = await fetch(`http://localhost:8000/tasks/${task.id}/`, {
                        method: "PATCH",
                        body: JSON.stringify({
                            name: this.editedItem.name,
                        }),
                        headers: {
                            'Content-Type': 'application/json'
                        }
                    });

                    if (response.ok) {
                        Object.assign(this.tasks[this.editedIndex], this.editedItem);
                    }
                } else {
                    const response = await fetch("http://localhost:8000/tasks/", {
                        method: "POST",
                        body: JSON.stringify(this.editedItem),
                        headers: {
                            'Content-Type': 'application/json'
                        },
                    });

                    const createdTask = await response.json();

                    if (response.ok) {
                        this.tasks.push(createdTask);
                    }
                }
                this.close();
            },
        }
    }
</script>

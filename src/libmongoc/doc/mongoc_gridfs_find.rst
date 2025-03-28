:man_page: mongoc_gridfs_find

mongoc_gridfs_find()
====================

.. warning::
   .. deprecated:: 1.5.0

      This function is deprecated, use :symbol:`mongoc_gridfs_find_with_opts` instead.

Synopsis
--------

.. code-block:: c

  mongoc_gridfs_file_list_t *
  mongoc_gridfs_find (mongoc_gridfs_t *gridfs,
                      const bson_t *query);

Parameters
----------

* ``gridfs``: A :symbol:`mongoc_gridfs_t`.
* ``query``: A :symbol:`bson:bson_t`.

Description
-----------

Finds all gridfs files matching ``query``. You can iterate the matched gridfs files with the resulting file list.

.. include:: includes/retryable-read.txt

Returns
-------

A newly allocated :symbol:`mongoc_gridfs_file_list_t` that should be freed with :symbol:`mongoc_gridfs_file_list_destroy()` when no longer in use.

